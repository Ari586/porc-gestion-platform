import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Service managing a single WebRTC peer‑to‑peer call, using Firestore as
/// the signaling channel for SDP offer/answer and ICE candidate exchange.
class WebRTCCallService {
  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  static const String _signalingCollection = 'porc_webrtc_signaling';
  static const String _candidatesSubcollection = 'candidates';

  static Map<String, dynamic> _buildIceConfig() {
    return <String, dynamic>{
      'iceServers': <Map<String, dynamic>>[
        <String, dynamic>{'urls': 'stun:stun.l.google.com:19302'},
        <String, dynamic>{'urls': 'stun:stun1.l.google.com:19302'},
        <String, dynamic>{
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
        <String, dynamic>{
          'urls': 'turn:openrelay.metered.ca:443',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
        <String, dynamic>{
          'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
      ],
    };
  }

  static Map<String, dynamic> _buildSdpConstraints() {
    return <String, dynamic>{
      'mandatory': <String, dynamic>{
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': <Map<String, dynamic>>[],
    };
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
  bool _disposed = false;
  String? _sessionId;
  String _role = 'caller'; // 'caller' or 'callee'

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _signalingSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _candidatesSubscription;

  /// Called when the remote stream becomes available.
  void Function(MediaStream stream)? onRemoteStream;

  /// Called when the peer connection state changes.
  void Function(RTCPeerConnectionState state)? onConnectionStateChange;

  /// Called when the call ends (remote hangup or ICE failure).
  void Function()? onCallEnded;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isVideo => _isVideo;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize renderers and acquire the local media stream.
  Future<void> initialize({required bool isVideo}) async {
    _isVideo = isVideo;
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
    final offer = await _peerConnection!.createOffer(_buildSdpConstraints());
    await _peerConnection!.setLocalDescription(offer);

    // Write offer + metadata to Firestore
    final Map<String, dynamic> payload = <String, dynamic>{
      'offer': <String, dynamic>{'sdp': offer.sdp, 'type': offer.type},
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
        onCallEnded?.call();
        return;
      }

      if (data['answer'] != null) {
        final remoteDesc = await _peerConnection!.getRemoteDescription();
        if (remoteDesc == null) {
          final answer = RTCSessionDescription(
            data['answer']['sdp'] as String,
            data['answer']['type'] as String,
          );
          try {
            await _peerConnection!.setRemoteDescription(answer);
          } catch (_) {}
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
              final data = change.doc.data()!;
              _peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'] as String,
                  data['sdpMid'] as String,
                  data['sdpMLineIndex'] as int,
                ),
              );
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

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;
    final data = snapshot.data()!;
    if (data['offer'] == null) return;

    // Set remote offer
    final offer = RTCSessionDescription(
      data['offer']['sdp'] as String,
      data['offer']['type'] as String,
    );
    await _peerConnection!.setRemoteDescription(offer);

    // Create SDP answer
    final answer = await _peerConnection!.createAnswer(_buildSdpConstraints());
    await _peerConnection!.setLocalDescription(answer);

    // Write answer to Firestore
    await docRef.update(<String, dynamic>{
      'answer': <String, dynamic>{'sdp': answer.sdp, 'type': answer.type},
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
              final data = change.doc.data()!;
              _peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'] as String,
                  data['sdpMid'] as String,
                  data['sdpMLineIndex'] as int,
                ),
              );
            }
          }
        });

    // Listen for hangup
    _signalingSubscription = docRef.snapshots().listen((snap) {
      if (_disposed) return;
      final d = snap.data();
      if (d != null && d['hangUp'] == true) {
        onCallEnded?.call();
      }
    });
  }

  /// Signal hangup to the remote peer via Firestore, then clean up.
  Future<void> hangUp(String sessionId) async {
    try {
      await FirebaseFirestore.instance
          .collection(_signalingCollection)
          .doc(sessionId)
          .update(<String, dynamic>{'hangUp': true});
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

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_buildIceConfig());

    // Add local tracks
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
    }

    // Handle incoming remote tracks
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        remoteRenderer.srcObject = _remoteStream;
        onRemoteStream?.call(_remoteStream!);
      }
    };

    // Connection state
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      onConnectionStateChange?.call(state);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        onCallEnded?.call();
      }
    };

    // Send ICE candidates to Firestore
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_disposed || _sessionId == null) return;
      FirebaseFirestore.instance
          .collection(_signalingCollection)
          .doc(_sessionId)
          .collection(_candidatesSubcollection)
          .add(<String, dynamic>{
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'from': _role,
          });
    };
  }

  Future<void> _cleanUp() async {
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
}
