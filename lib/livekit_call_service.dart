import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';

class LiveKitTokenPayload {
  final String url;
  final String token;

  const LiveKitTokenPayload({required this.url, required this.token});
}

/// LiveKit call service (1:1) with Firestore signaling hangup watcher.
///
/// It keeps the existing app signaling doc (`porc_webrtc_signaling/{sessionId}`)
/// for incoming call detection and hangup propagation, but moves media transport
/// to LiveKit for better cross-network reliability.
class LiveKitCallService {
  static const String _tokenEndpoint = String.fromEnvironment(
    'LIVEKIT_TOKEN_ENDPOINT',
  );
  static const String _fallbackLiveKitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
  );
  static const String _clientSharedSecret = String.fromEnvironment(
    'LIVEKIT_CLIENT_SECRET',
  );
  static const int _requestTimeoutSeconds = 12;
  static const String _signalingCollection = 'porc_webrtc_signaling';

  static bool get isConfigured => _tokenEndpoint.trim().isNotEmpty;

  Room? _room;
  bool _disposed = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _signalingSubscription;

  /// Triggered when a remote party rejects/hangs up (via signaling doc).
  void Function()? onRemoteHangUp;

  Room? get room => _room;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get hasRemoteParticipant =>
      _room?.remoteParticipants.isNotEmpty ?? false;

  VideoTrack? get localVideoTrack {
    return _firstVideoTrackForParticipant(_room?.localParticipant);
  }

  VideoTrack? get remoteVideoTrack {
    final room = _room;
    if (room == null) {
      return null;
    }
    for (final participant in room.remoteParticipants.values) {
      final track = _firstVideoTrackForParticipant(participant);
      if (track != null) {
        return track;
      }
    }
    return null;
  }

  Future<void> connect({
    required String sessionId,
    required String roomName,
    required String participantId,
    required String participantName,
    required bool enableVideo,
  }) async {
    if (_disposed) {
      throw StateError('Service LiveKit déjà libéré.');
    }
    if (!isConfigured) {
      throw StateError(
        'LIVEKIT_TOKEN_ENDPOINT manquant. Configurez --dart-define=LIVEKIT_TOKEN_ENDPOINT=...',
      );
    }

    final tokenPayload = await _fetchToken(
      roomName: roomName,
      participantId: participantId,
      participantName: participantName,
      sessionId: sessionId,
    );

    final room = Room(
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );
    _room = room;
    await room.connect(tokenPayload.url, tokenPayload.token);
    await room.localParticipant?.setMicrophoneEnabled(true);
    await room.localParticipant?.setCameraEnabled(enableVideo);
    _isMuted = false;
    _isCameraOff = !enableVideo;

    _watchSignaling(sessionId);
  }

  Future<void> toggleMute() async {
    final room = _room;
    if (room == null) {
      return;
    }
    final nextMuted = !_isMuted;
    await room.localParticipant?.setMicrophoneEnabled(!nextMuted);
    _isMuted = nextMuted;
  }

  Future<void> toggleCamera() async {
    final room = _room;
    if (room == null) {
      return;
    }
    final nextOff = !_isCameraOff;
    await room.localParticipant?.setCameraEnabled(!nextOff);
    _isCameraOff = nextOff;
  }

  Future<void> switchCamera() async {
    // The camera switch API differs by platform/package versions.
    // Keep a safe no-op when unavailable.
    final room = _room;
    if (room == null) {
      return;
    }
    try {
      final dynamic participant = room.localParticipant;
      final dynamic currentPosition = participant.cameraPosition;
      final dynamic nextPosition = currentPosition == CameraPosition.front
          ? CameraPosition.back
          : CameraPosition.front;
      await participant.setCameraPosition(nextPosition);
    } catch (_) {
      // No-op fallback.
    }
  }

  Future<void> hangUp(String sessionId) async {
    final id = sessionId.trim();
    if (id.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(_signalingCollection)
            .doc(id)
            .set(<String, dynamic>{'hangUp': true}, SetOptions(merge: true));
      } catch (_) {
        // Keep disconnect path even if signaling update fails.
      }
    }
    await _disconnectInternal();
  }

  Future<void> dispose() async {
    _disposed = true;
    await _disconnectInternal();
  }

  Future<LiveKitTokenPayload> _fetchToken({
    required String roomName,
    required String participantId,
    required String participantName,
    required String sessionId,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_clientSharedSecret.trim().isNotEmpty) {
      headers['x-client-secret'] = _clientSharedSecret.trim();
    }

    final response = await http
        .post(
          Uri.parse(_tokenEndpoint),
          headers: headers,
          body: jsonEncode(<String, dynamic>{
            'roomName': roomName,
            'participantId': participantId,
            'participantName': participantName,
            'sessionId': sessionId,
          }),
        )
        .timeout(const Duration(seconds: _requestTimeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Token LiveKit refusé (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw StateError('Réponse token LiveKit invalide.');
    }
    final map = Map<String, dynamic>.from(decoded);
    final token = _readString(map['token']).trim();
    final endpointUrl = _readString(map['url']).trim();
    final resolvedUrl = endpointUrl.isNotEmpty
        ? endpointUrl
        : _fallbackLiveKitUrl.trim();

    if (token.isEmpty || resolvedUrl.isEmpty) {
      throw StateError('Token/url LiveKit manquant dans la réponse backend.');
    }
    return LiveKitTokenPayload(url: resolvedUrl, token: token);
  }

  void _watchSignaling(String sessionId) {
    _signalingSubscription?.cancel();
    final id = sessionId.trim();
    if (id.isEmpty) {
      return;
    }
    _signalingSubscription = FirebaseFirestore.instance
        .collection(_signalingCollection)
        .doc(id)
        .snapshots()
        .listen((snapshot) {
          if (_disposed) {
            return;
          }
          final data = snapshot.data();
          if (data == null) {
            return;
          }
          if (data['hangUp'] == true) {
            onRemoteHangUp?.call();
          }
        });
  }

  Future<void> _disconnectInternal() async {
    await _signalingSubscription?.cancel();
    _signalingSubscription = null;
    final room = _room;
    _room = null;
    if (room == null) {
      return;
    }
    try {
      await room.disconnect();
    } catch (_) {}
    try {
      room.dispose();
    } catch (_) {}
  }

  VideoTrack? _firstVideoTrackForParticipant(dynamic participant) {
    if (participant == null) {
      return null;
    }

    final publications = _extractVideoPublications(participant);
    for (final publication in publications) {
      try {
        final dynamic track = publication.track;
        final dynamic muted = publication.muted;
        if (track is VideoTrack && muted != true) {
          return track;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  List<dynamic> _extractVideoPublications(dynamic participant) {
    try {
      final dynamic raw = participant.videoTrackPublications;
      if (raw is Iterable) {
        return raw.toList();
      }
      if (raw is Map) {
        return raw.values.toList();
      }
    } catch (_) {}
    try {
      final dynamic raw = participant.videoTracks;
      if (raw is Iterable) {
        return raw.toList();
      }
      if (raw is Map) {
        return raw.values.toList();
      }
    } catch (_) {}
    return const <dynamic>[];
  }

  String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
