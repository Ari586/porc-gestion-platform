import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Service managing a single WebRTC peer‑to‑peer call, using Firestore as
/// the signaling channel for SDP offer/answer and ICE candidate exchange.
class WebRTCCallService {
  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  static const String _signalingCollection = 'porc_webrtc_signaling';
  static const String _candidatesSubcollection = 'candidates';
  static const bool _forceRelay = bool.fromEnvironment(
    'WEBRTC_FORCE_RELAY',
    defaultValue: true,
  );
  static const String _stunUrlsFromEnv = String.fromEnvironment(
    'WEBRTC_STUN_URLS',
  );
  static const String _turnUrlsFromEnv = String.fromEnvironment(
    'WEBRTC_TURN_URLS',
  );
  static const String _turnUsernameFromEnv = String.fromEnvironment(
    'WEBRTC_TURN_USERNAME',
  );
  static const String _turnCredentialFromEnv = String.fromEnvironment(
    'WEBRTC_TURN_CREDENTIAL',
  );
  static const String _turnUrls2FromEnv = String.fromEnvironment(
    'WEBRTC_TURN_URLS_2',
  );
  static const String _turnUsername2FromEnv = String.fromEnvironment(
    'WEBRTC_TURN_USERNAME_2',
  );
  static const String _turnCredential2FromEnv = String.fromEnvironment(
    'WEBRTC_TURN_CREDENTIAL_2',
  );
  static const String _turnUrls3FromEnv = String.fromEnvironment(
    'WEBRTC_TURN_URLS_3',
  );
  static const String _turnUsername3FromEnv = String.fromEnvironment(
    'WEBRTC_TURN_USERNAME_3',
  );
  static const String _turnCredential3FromEnv = String.fromEnvironment(
    'WEBRTC_TURN_CREDENTIAL_3',
  );
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _disconnectGracePeriod = Duration(seconds: 12);

  static Map<String, dynamic> _buildIceConfig() {
    final turnServers = _buildTurnServers();
    final hasTurn = turnServers.isNotEmpty;
    final iceServers = <Map<String, dynamic>>[
      ..._buildStunServers(),
      ...turnServers,
    ];
    return <String, dynamic>{
      // Cross-network calls on mobile operators are much more reliable when
      // relay is enforced through TURN. If TURN is missing, fall back to `all`
      // so calls still have a chance to connect on same/private networks.
      'iceTransportPolicy': (_forceRelay && hasTurn) ? 'relay' : 'all',
      'iceCandidatePoolSize': 8,
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      // Keep both peers on unified-plan to avoid browser/engine SDP mismatch.
      'sdpSemantics': 'unified-plan',
      'iceServers': iceServers,
    };
  }

  static List<Map<String, dynamic>> _buildStunServers() {
    final fromEnv = _splitCsv(_stunUrlsFromEnv);
    final urls = fromEnv.isNotEmpty
        ? fromEnv
        : const [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
          ];
    return urls
        .where((url) => url.trim().isNotEmpty)
        .map((url) => <String, dynamic>{'urls': url.trim()})
        .toList();
  }

  static List<Map<String, dynamic>> _buildTurnServers() {
    final turnServers = <Map<String, dynamic>>[];

    void addTurnBundle({
      required List<String> urls,
      required String username,
      required String credential,
    }) {
      if (urls.isEmpty ||
          username.trim().isEmpty ||
          credential.trim().isEmpty) {
        return;
      }
      turnServers.add(<String, dynamic>{
        'urls': urls,
        'username': username.trim(),
        'credential': credential.trim(),
      });
    }

    addTurnBundle(
      urls: _splitCsv(_turnUrlsFromEnv),
      username: _turnUsernameFromEnv,
      credential: _turnCredentialFromEnv,
    );
    addTurnBundle(
      urls: _splitCsv(_turnUrls2FromEnv),
      username: _turnUsername2FromEnv,
      credential: _turnCredential2FromEnv,
    );
    addTurnBundle(
      urls: _splitCsv(_turnUrls3FromEnv),
      username: _turnUsername3FromEnv,
      credential: _turnCredential3FromEnv,
    );
    return turnServers;
  }

  static List<String> _splitCsv(String raw) {
    if (raw.trim().isEmpty) {
      return const [];
    }
    final seen = <String>{};
    final values = <String>[];
    for (final item in raw.split(',')) {
      final value = item.trim();
      if (value.isEmpty || seen.contains(value)) {
        continue;
      }
      seen.add(value);
      values.add(value);
    }
    return values;
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _isVideo = true;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isAudioFallback = false;
  bool _disposed = false;
  bool _callEndedNotified = false;
  String? _sessionId;
  String _role = 'caller'; // 'caller' or 'callee'
  Timer? _connectTimeoutTimer;
  Timer? _disconnectTimer;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _signalingSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _candidatesSubscription;

  /// Called when the remote stream becomes available.
  void Function(MediaStream stream)? onRemoteStream;

  /// Called when the peer connection state changes.
  void Function(RTCPeerConnectionState state)? onConnectionStateChange;

  /// Called when the ICE connection state changes.
  void Function(RTCIceConnectionState state)? onIceConnectionStateChange;

  /// Called when call degrades to audio-only mode for stability.
  void Function()? onAudioFallback;

  /// Called when the call ends (remote hangup or ICE failure).
  void Function()? onCallEnded;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isVideo => _isVideo;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isAudioFallback => _isAudioFallback;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize renderers and acquire the local media stream.
  Future<void> initialize({required bool isVideo}) async {
    _isVideo = isVideo;
    _isAudioFallback = false;
    _callEndedNotified = false;
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    final Map<String, dynamic> mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': isVideo
          ? <String, dynamic>{
              'facingMode': 'user',
              'width': <String, dynamic>{'ideal': 640},
              'height': <String, dynamic>{'ideal': 480},
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;
  }

  /// Create the peer connection, generate an SDP offer, and write it to
  /// Firestore. The **caller** invokes this.
  ///
  /// [meta] is optional caller/callee metadata written alongside the offer so
  /// that a remote listener can detect incoming calls in real‑time.
  Future<void> createOffer(
    String sessionId, {
    Map<String, dynamic>? meta,
  }) async {
    _sessionId = sessionId;
    _role = 'caller';
    await _createPeerConnection();
    if (_disposed) return;

    final docRef = FirebaseFirestore.instance
        .collection(_signalingCollection)
        .doc(sessionId);

    // Create SDP offer
    final offer = await _peerConnection!.createOffer();
    final offerType = _readString(offer.type).trim();
    final offerSdp = _normalizeSdp(_readString(offer.sdp));
    if (offerType.isEmpty || offerSdp.isEmpty) {
      throw StateError('Offre SDP invalide.');
    }
    await _peerConnection!.setLocalDescription(
      RTCSessionDescription(offerSdp, offerType),
    );

    // Write offer + metadata to Firestore
    final Map<String, dynamic> payload = <String, dynamic>{
      'offer': <String, dynamic>{'sdp': offerSdp, 'type': offerType},
      'createdAt': FieldValue.serverTimestamp(),
      'hangUp': false,
    };
    if (meta != null) {
      payload.addAll(meta);
    }
    await docRef.set(payload);

    // Listen for the remote answer + hangup
    _signalingSubscription = docRef.snapshots().listen((snapshot) async {
      if (_disposed || _peerConnection == null) return;
      final data = snapshot.data();
      if (data == null) return;

      if (data['hangUp'] == true) {
        _notifyCallEndedOnce();
        return;
      }

      if (data['answer'] != null) {
        final remoteDesc = await _peerConnection!.getRemoteDescription();
        if (remoteDesc == null) {
          final rawAnswer = data['answer'];
          if (rawAnswer is! Map) {
            return;
          }
          final answerMap = Map<String, dynamic>.from(rawAnswer);
          final answerSdp = _readString(answerMap['sdp']).trim();
          final answerType = _readString(answerMap['type']).trim();
          if (answerSdp.isEmpty || answerType.isEmpty) {
            return;
          }
          try {
            await _setRemoteDescriptionSafely(sdp: answerSdp, type: answerType);
          } catch (_) {
            _notifyCallEndedOnce();
          }
        }
      }
    });

    // Listen for remote ICE candidates (from callee)
    _candidatesSubscription = docRef
        .collection(_candidatesSubcollection)
        .where('from', isEqualTo: 'callee')
        .snapshots()
        .listen((snapshot) {
          if (_disposed || _peerConnection == null) return;
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data == null) continue;
              _addRemoteCandidateFromJson(data);
            }
          }
        });
  }

  /// Read the remote offer, set it, create an SDP answer, and write it to
  /// Firestore. The **callee** invokes this.
  Future<void> answerCall(String sessionId) async {
    _sessionId = sessionId;
    _role = 'callee';
    await _createPeerConnection();
    if (_disposed) return;

    final docRef = FirebaseFirestore.instance
        .collection(_signalingCollection)
        .doc(sessionId);

    final data = await _waitForOfferPayload(docRef);
    if (_disposed || _peerConnection == null) return;
    final rawOffer = data['offer'];
    if (rawOffer is! Map) {
      throw StateError('Offre d’appel invalide.');
    }
    final offerMap = Map<String, dynamic>.from(rawOffer);
    final offerSdp = _normalizeSdp(_readString(offerMap['sdp']));
    final offerType = _readString(offerMap['type']).trim();
    if (offerSdp.isEmpty || offerType.isEmpty) {
      throw StateError('Offre d’appel incomplète.');
    }

    // Set remote offer
    await _setRemoteDescriptionSafely(sdp: offerSdp, type: offerType);

    // Create SDP answer
    final answer = await _peerConnection!.createAnswer();
    final answerType = _readString(answer.type).trim();
    final answerSdp = _normalizeSdp(_readString(answer.sdp));
    if (answerType.isEmpty || answerSdp.isEmpty) {
      throw StateError('Réponse SDP invalide.');
    }
    await _peerConnection!.setLocalDescription(
      RTCSessionDescription(answerSdp, answerType),
    );

    // Write answer to Firestore
    await docRef.update(<String, dynamic>{
      'answer': <String, dynamic>{'sdp': answerSdp, 'type': answerType},
      'answeredByAuthUid': _firebaseAuthUid(),
      'answeredAt': FieldValue.serverTimestamp(),
    });

    // Listen for remote ICE candidates (from caller)
    _candidatesSubscription = docRef
        .collection(_candidatesSubcollection)
        .where('from', isEqualTo: 'caller')
        .snapshots()
        .listen((snapshot) {
          if (_disposed || _peerConnection == null) return;
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data == null) continue;
              _addRemoteCandidateFromJson(data);
            }
          }
        });

    // Listen for hangup
    _signalingSubscription = docRef.snapshots().listen((snap) {
      if (_disposed) return;
      final d = snap.data();
      if (d != null && d['hangUp'] == true) {
        _notifyCallEndedOnce();
      }
    });
  }

  /// Signal hangup to the remote peer via Firestore, then clean up.
  Future<void> hangUp(String sessionId) async {
    try {
      await FirebaseFirestore.instance
          .collection(_signalingCollection)
          .doc(sessionId)
          .set(<String, dynamic>{
            'hangUp': true,
            'hangUpByAuthUid': _firebaseAuthUid(),
            'hangUpAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (_) {}
    await _cleanUp();
  }

  /// Clean up without signaling (for when remote already hung up).
  Future<void> dispose() async {
    _disposed = true;
    await _cleanUp();
  }

  // ---------------------------------------------------------------------------
  // Media controls
  // ---------------------------------------------------------------------------

  void toggleMute() {
    if (_localStream == null) return;
    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = !track.enabled;
    }
    _isMuted = !_isMuted;
  }

  void toggleCamera() {
    if (_localStream == null || !_isVideo) return;
    for (final track in _localStream!.getVideoTracks()) {
      track.enabled = !track.enabled;
    }
    _isCameraOff = !_isCameraOff;
  }

  Future<void> switchCamera() async {
    if (_localStream == null || !_isVideo) return;
    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      await Helper.switchCamera(videoTracks.first);
    }
  }

  Future<void> switchToAudioFallback() async {
    if (_localStream == null || _isAudioFallback) {
      return;
    }
    for (final track in _localStream!.getVideoTracks()) {
      track.enabled = false;
      try {
        await track.stop();
      } catch (_) {
        // Keep fallback path resilient.
      }
    }
    _isCameraOff = true;
    _isVideo = false;
    _isAudioFallback = true;
    onAudioFallback?.call();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _waitForOfferPayload(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    final existing = await docRef.get();
    final existingData = existing.data();
    if (existingData != null && existingData['offer'] != null) {
      return existingData;
    }

    final completer = Completer<Map<String, dynamic>>();
    late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
    subscription;
    subscription = docRef.snapshots().listen(
      (snapshot) {
        final data = snapshot.data();
        if (data == null || data['offer'] == null) {
          return;
        }
        if (!completer.isCompleted) {
          completer.complete(data);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw StateError('Offre d’appel introuvable (timeout).');
    } finally {
      await subscription.cancel();
    }
  }

  void _addRemoteCandidateFromJson(Map<String, dynamic> data) {
    if (_disposed || _peerConnection == null) {
      return;
    }
    final candidate = _readString(data['candidate']).trim();
    final sdpMLineIndex = _readInt(data['sdpMLineIndex']);
    if (candidate.isEmpty || sdpMLineIndex == null) {
      return;
    }
    final sdpMid = data['sdpMid']?.toString();
    _peerConnection!.addCandidate(
      RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
    );
  }

  String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_readString(value));
  }

  String _normalizeSdp(String rawSdp) {
    final normalizedBreaks = rawSdp
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final lines = normalizedBreaks
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return '';
    }
    return '${lines.join('\r\n')}\r\n';
  }

  String _stripLegacySsrcLines(String sdp) {
    final lines = sdp
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((line) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) {
            return false;
          }
          if (trimmed.startsWith('a=ssrc:') ||
              trimmed.startsWith('a=ssrc-group:')) {
            return false;
          }
          return true;
        })
        .toList();
    if (lines.isEmpty) {
      return '';
    }
    return '${lines.join('\r\n')}\r\n';
  }

  Future<void> _setRemoteDescriptionSafely({
    required String sdp,
    required String type,
  }) async {
    final normalizedSdp = _normalizeSdp(sdp);
    if (normalizedSdp.isEmpty) {
      throw StateError('SDP distant vide.');
    }

    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(normalizedSdp, type),
      );
      return;
    } catch (_) {
      // Retry below with a compatibility fallback for legacy SSRC attributes.
    }

    final fallbackSdp = _stripLegacySsrcLines(normalizedSdp);
    if (fallbackSdp.isEmpty || fallbackSdp == normalizedSdp) {
      throw StateError('Échec setRemoteDescription: SDP non compatible.');
    }

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(fallbackSdp, type),
    );
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_buildIceConfig());

    // Add local tracks
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
    }

    // Legacy Plan-B fallback (some platforms still trigger this).
    _peerConnection!.onAddStream = (MediaStream stream) {
      if (_disposed) {
        return;
      }
      _setRemoteStream(stream);
    };

    // Unified-Plan: handle incoming remote tracks.
    _peerConnection!.onTrack = (RTCTrackEvent event) async {
      if (_disposed) {
        return;
      }

      if (event.streams.isNotEmpty) {
        _setRemoteStream(event.streams.first);
        return;
      }

      // Some peers deliver track events without streams on web/mobile interop.
      // Build a synthetic remote stream so renderer/UI can bind immediately.
      final track = event.track;
      if (track.kind != 'audio' && track.kind != 'video') {
        return;
      }
      MediaStream? target = _remoteStream;
      if (target == null) {
        try {
          target = await createLocalMediaStream(
            'remote_${DateTime.now().microsecondsSinceEpoch}',
          );
        } catch (_) {
          target = null;
        }
      }
      if (target == null) {
        return;
      }
      final exists = target.getTracks().any((item) => item.id == track.id);
      if (!exists) {
        try {
          await target.addTrack(track, addToNative: false);
        } catch (_) {
          try {
            await target.addTrack(track);
          } catch (_) {
            // Keep call alive even if track merge fails.
          }
        }
      }
      _setRemoteStream(target);
    };

    // Connection state
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      onConnectionStateChange?.call(state);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _connectTimeoutTimer?.cancel();
        _disconnectTimer?.cancel();
        if (_remoteStream != null) {
          onRemoteStream?.call(_remoteStream!);
        }
        return;
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        if (_isVideo && !_isAudioFallback) {
          unawaited(switchToAudioFallback());
        }
        _startDisconnectGraceTimer();
        return;
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _notifyCallEndedOnce();
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      onIceConnectionStateChange?.call(state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _connectTimeoutTimer?.cancel();
        _disconnectTimer?.cancel();
        return;
      }
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        if (_isVideo && !_isAudioFallback) {
          unawaited(switchToAudioFallback());
        }
        _startDisconnectGraceTimer();
        return;
      }
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        _notifyCallEndedOnce();
      }
    };

    // Send ICE candidates to Firestore
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_disposed || _sessionId == null) return;
      final candidateValue = candidate.candidate?.trim() ?? '';
      if (candidateValue.isEmpty || candidate.sdpMLineIndex == null) {
        return;
      }
      FirebaseFirestore.instance
          .collection(_signalingCollection)
          .doc(_sessionId)
          .collection(_candidatesSubcollection)
          .add(<String, dynamic>{
            'candidate': candidateValue,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'from': _role,
            'authUid': _firebaseAuthUid(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    };
    _startConnectWatchdog();
  }

  Future<void> _cleanUp() async {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    _disconnectTimer?.cancel();
    _disconnectTimer = null;
    await _signalingSubscription?.cancel();
    _signalingSubscription = null;
    await _candidatesSubscription?.cancel();
    _candidatesSubscription = null;

    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;

    _remoteStream?.dispose();
    _remoteStream = null;

    await _peerConnection?.close();
    _peerConnection = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    try {
      await localRenderer.dispose();
    } catch (_) {}
    try {
      await remoteRenderer.dispose();
    } catch (_) {}
  }

  void _setRemoteStream(MediaStream stream) {
    _remoteStream = stream;
    remoteRenderer.srcObject = stream;
    onRemoteStream?.call(stream);
  }

  void _startConnectWatchdog() {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = Timer(_connectTimeout, () {
      if (_disposed) {
        return;
      }
      _notifyCallEndedOnce();
    });
  }

  void _startDisconnectGraceTimer() {
    if (_disconnectTimer?.isActive ?? false) {
      return;
    }
    _disconnectTimer = Timer(_disconnectGracePeriod, () {
      if (_disposed) {
        return;
      }
      _notifyCallEndedOnce();
    });
  }

  void _notifyCallEndedOnce() {
    if (_callEndedNotified) {
      return;
    }
    _callEndedNotified = true;
    onCallEnded?.call();
  }

  String _firebaseAuthUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return '';
    }
    return uid.trim();
  }
}
