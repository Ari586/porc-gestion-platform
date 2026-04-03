import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketChatCallPage extends StatefulWidget {
  const SocketChatCallPage({super.key});

  @override
  State<SocketChatCallPage> createState() => _SocketChatCallPageState();
}

class _SocketChatCallPageState extends State<SocketChatCallPage> {
  static const String _defaultServerUrl = String.fromEnvironment(
    'SOCKET_SERVER_URL',
    defaultValue:
        'https://porc-socket-signaling-520994990737.us-central1.run.app',
  );
  static const String _defaultRoomId = String.fromEnvironment(
    'SOCKET_ROOM_ID',
    defaultValue: 'chat-123',
  );
  static const String _defaultUsername = String.fromEnvironment(
    'SOCKET_USERNAME',
    defaultValue: 'Flutter User',
  );
  static const String _stunUrlsEnv = String.fromEnvironment('WEBRTC_STUN_URLS');
  static const String _turnUrlsEnv = String.fromEnvironment('WEBRTC_TURN_URLS');
  static const String _turnUsernameEnv = String.fromEnvironment(
    'WEBRTC_TURN_USERNAME',
  );
  static const String _turnCredentialEnv = String.fromEnvironment(
    'WEBRTC_TURN_CREDENTIAL',
  );

  final TextEditingController _messageController = TextEditingController();
  final List<_SocketChatMessage> _messages = <_SocketChatMessage>[];
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final ScrollController _listController = ScrollController();

  late final String _userId;
  late final String _username;
  late final String _roomId;
  late final String _serverUrl;

  io.Socket? _socket;
  String _socketId = '';
  bool _socketConnected = false;
  String? _socketError;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _inCall = false;
  bool _remoteConnected = false;
  bool _cameraEnabled = true;
  bool _audioEnabled = true;
  bool _isBusyCallTransition = false;

  @override
  void initState() {
    super.initState();
    _userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _username = _defaultUsername;
    _roomId = _defaultRoomId;
    _serverUrl = _defaultServerUrl;
    _initialize();
  }

  Future<void> _initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _connectSocket();
  }

  void _connectSocket() {
    final socket = io.io(_serverUrl, <String, dynamic>{
      'transports': <String>['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 12,
      'reconnectionDelay': 800,
      'timeout': 15000,
    });
    _socket = socket;

    socket.onConnect((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _socketConnected = true;
        _socketError = null;
        _socketId = socket.id ?? '';
      });
      socket.emit('register_user', <String, dynamic>{
        'userId': _userId,
        'username': _username,
      });
      socket.emit('join_room', _roomId);
      _appendSystemMessage('Connecte a $_serverUrl (room: $_roomId).');
    });

    socket.onDisconnect((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _socketConnected = false;
      });
    });

    socket.onConnectError((dynamic error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _socketError = error.toString();
      });
    });

    socket.onError((dynamic error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _socketError = error.toString();
      });
    });

    socket.on('receive_message', (dynamic payload) {
      final map = _asMap(payload);
      if (map == null) {
        return;
      }
      final text = _readString(map['text']).trim();
      if (text.isEmpty) {
        return;
      }
      final senderId = _readString(map['senderId']).trim();
      _appendMessage(
        _SocketChatMessage(
          senderId: senderId,
          text: text,
          sentAt: DateTime.now(),
          isMine: senderId == _userId || senderId == _socketId,
        ),
      );
    });

    socket.on('webrtc_offer', (dynamic payload) async {
      final map = _asMap(payload);
      if (map == null) {
        return;
      }
      final senderId = _readString(map['senderId']).trim();
      if (senderId == _socketId) {
        return;
      }
      final offerMap = _asMap(map['offer']);
      if (offerMap == null) {
        return;
      }
      await _handleReceiveOffer(offerMap);
    });

    socket.on('webrtc_answer', (dynamic payload) async {
      final map = _asMap(payload);
      if (map == null) {
        return;
      }
      final senderId = _readString(map['senderId']).trim();
      if (senderId == _socketId) {
        return;
      }
      final answerMap = _asMap(map['answer']);
      if (answerMap == null) {
        return;
      }
      await _handleReceiveAnswer(answerMap);
    });

    socket.on('webrtc_ice_candidate', (dynamic payload) async {
      final map = _asMap(payload);
      if (map == null) {
        return;
      }
      final senderId = _readString(map['senderId']).trim();
      if (senderId == _socketId) {
        return;
      }
      final candidateMap = _asMap(map['candidate']);
      if (candidateMap == null) {
        return;
      }
      await _handleReceiveIceCandidate(candidateMap);
    });

    socket.on('webrtc_hangup', (_) async {
      await _endCall(localOnly: true);
      _appendSystemMessage('Appel termine par le correspondant.');
    });

    socket.connect();
  }

  Future<RTCPeerConnection> _ensurePeerConnection() async {
    final existing = _peerConnection;
    if (existing != null) {
      return existing;
    }

    final connection = await createPeerConnection(_buildIceConfig());
    _peerConnection = connection;

    connection.onIceCandidate = (RTCIceCandidate candidate) {
      final socket = _socket;
      if (socket == null || !_socketConnected) {
        return;
      }
      final candidateValue = candidate.candidate?.trim() ?? '';
      if (candidateValue.isEmpty || candidate.sdpMLineIndex == null) {
        return;
      }
      socket.emit('webrtc_ice_candidate', <String, dynamic>{
        'roomId': _roomId,
        'candidate': <String, dynamic>{
          'candidate': candidateValue,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    connection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isEmpty || !mounted) {
        return;
      }
      final stream = event.streams.first;
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = stream;
        _remoteConnected = true;
      });
    };

    connection.onConnectionState = (RTCPeerConnectionState state) {
      if (!mounted) {
        return;
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _endCall(localOnly: true);
      }
    };

    return connection;
  }

  Future<void> _ensureLocalMedia() async {
    if (_localStream != null) {
      return;
    }
    final stream = await navigator.mediaDevices.getUserMedia(<String, dynamic>{
      'audio': true,
      'video': <String, dynamic>{
        'facingMode': 'user',
        'width': <String, dynamic>{'ideal': 640},
        'height': <String, dynamic>{'ideal': 480},
      },
    });
    _localStream = stream;
    _localRenderer.srcObject = stream;
    final connection = await _ensurePeerConnection();
    for (final track in stream.getTracks()) {
      await connection.addTrack(track, stream);
    }
  }

  Future<void> _startCall() async {
    if (_isBusyCallTransition) {
      return;
    }
    if (!_socketConnected) {
      _showError('Socket non connecte.');
      return;
    }

    _isBusyCallTransition = true;
    try {
      await _ensureLocalMedia();
      final connection = await _ensurePeerConnection();
      final offer = await connection.createOffer(<String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await connection.setLocalDescription(offer);

      _socket?.emit('webrtc_offer', <String, dynamic>{
        'roomId': _roomId,
        'offer': <String, dynamic>{'sdp': offer.sdp, 'type': offer.type},
      });
      if (!mounted) {
        return;
      }
      setState(() {
        _inCall = true;
        _remoteConnected = false;
      });
      _appendSystemMessage('Appel video en cours...');
    } catch (error) {
      _showError('Impossible de demarrer l\'appel: $error');
      await _endCall(localOnly: true);
    } finally {
      _isBusyCallTransition = false;
    }
  }

  Future<void> _handleReceiveOffer(Map<String, dynamic> offerData) async {
    if (_isBusyCallTransition) {
      return;
    }
    _isBusyCallTransition = true;
    try {
      await _ensureLocalMedia();
      final connection = await _ensurePeerConnection();

      final sdp = _readString(offerData['sdp']).trim();
      final type = _readString(offerData['type']).trim();
      if (sdp.isEmpty || type.isEmpty) {
        return;
      }

      await connection.setRemoteDescription(RTCSessionDescription(sdp, type));
      final answer = await connection.createAnswer(<String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await connection.setLocalDescription(answer);

      _socket?.emit('webrtc_answer', <String, dynamic>{
        'roomId': _roomId,
        'answer': <String, dynamic>{'sdp': answer.sdp, 'type': answer.type},
      });

      if (!mounted) {
        return;
      }
      setState(() {
        _inCall = true;
      });
      _appendSystemMessage('Appel entrant accepte.');
    } catch (error) {
      _showError('Erreur de reponse a l\'appel: $error');
      await _endCall(localOnly: true);
    } finally {
      _isBusyCallTransition = false;
    }
  }

  Future<void> _handleReceiveAnswer(Map<String, dynamic> answerData) async {
    final connection = _peerConnection;
    if (connection == null) {
      return;
    }
    final sdp = _readString(answerData['sdp']).trim();
    final type = _readString(answerData['type']).trim();
    if (sdp.isEmpty || type.isEmpty) {
      return;
    }
    try {
      await connection.setRemoteDescription(RTCSessionDescription(sdp, type));
      if (!mounted) {
        return;
      }
      setState(() {
        _inCall = true;
      });
    } catch (_) {
      // Ignore invalid/duplicate answer events.
    }
  }

  Future<void> _handleReceiveIceCandidate(
    Map<String, dynamic> candidateData,
  ) async {
    final connection = _peerConnection;
    if (connection == null) {
      return;
    }
    final candidate = _readString(candidateData['candidate']).trim();
    final sdpMid = _readString(candidateData['sdpMid']).trim();
    final rawMLineIndex = candidateData['sdpMLineIndex'];
    final mLineIndex = rawMLineIndex is int
        ? rawMLineIndex
        : int.tryParse(rawMLineIndex.toString());
    if (candidate.isEmpty || mLineIndex == null) {
      return;
    }
    try {
      await connection.addCandidate(
        RTCIceCandidate(candidate, sdpMid.isEmpty ? null : sdpMid, mLineIndex),
      );
    } catch (_) {
      // Ignore malformed/late candidates.
    }
  }

  Future<void> _endCall({bool localOnly = false}) async {
    if (!localOnly) {
      _socket?.emit('webrtc_hangup', <String, dynamic>{'roomId': _roomId});
    }

    final stream = _localStream;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
      await stream.dispose();
    }
    _localStream = null;
    _localRenderer.srcObject = null;

    final remote = _remoteStream;
    if (remote != null) {
      await remote.dispose();
    }
    _remoteStream = null;
    _remoteRenderer.srcObject = null;

    final connection = _peerConnection;
    if (connection != null) {
      await connection.close();
    }
    _peerConnection = null;

    if (!mounted) {
      return;
    }
    setState(() {
      _inCall = false;
      _remoteConnected = false;
      _cameraEnabled = true;
      _audioEnabled = true;
    });
  }

  void _toggleAudio() {
    final stream = _localStream;
    if (stream == null) {
      return;
    }
    final enable = !_audioEnabled;
    for (final track in stream.getAudioTracks()) {
      track.enabled = enable;
    }
    setState(() {
      _audioEnabled = enable;
    });
  }

  void _toggleCamera() {
    final stream = _localStream;
    if (stream == null) {
      return;
    }
    final enable = !_cameraEnabled;
    for (final track in stream.getVideoTracks()) {
      track.enabled = enable;
    }
    setState(() {
      _cameraEnabled = enable;
    });
  }

  Future<void> _switchCamera() async {
    final stream = _localStream;
    if (stream == null) {
      return;
    }
    final tracks = stream.getVideoTracks();
    if (tracks.isEmpty) {
      return;
    }
    await Helper.switchCamera(tracks.first);
  }

  void _sendMessage() {
    final socket = _socket;
    final text = _messageController.text.trim();
    if (socket == null || !_socketConnected) {
      _showError('Socket non connecte.');
      return;
    }
    if (text.isEmpty) {
      return;
    }
    socket.emit('send_message', <String, dynamic>{
      'roomId': _roomId,
      'senderId': _userId,
      'text': text,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    _appendMessage(
      _SocketChatMessage(
        senderId: _userId,
        text: text,
        sentAt: DateTime.now(),
        isMine: true,
      ),
    );
    _messageController.clear();
  }

  void _appendSystemMessage(String text) {
    _appendMessage(
      _SocketChatMessage(
        senderId: 'system',
        text: text,
        sentAt: DateTime.now(),
        isMine: false,
        isSystem: true,
      ),
    );
  }

  void _appendMessage(_SocketChatMessage message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _messages.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) {
        return;
      }
      _listController.animateTo(
        _listController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB91C1C),
      ),
    );
  }

  Map<String, dynamic>? _asMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return null;
  }

  String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  Map<String, dynamic> _buildIceConfig() {
    final iceServers = <Map<String, dynamic>>[];

    final stunUrls = _splitCsv(_stunUrlsEnv);
    if (stunUrls.isNotEmpty) {
      iceServers.add(<String, dynamic>{'urls': stunUrls});
    } else {
      iceServers.add(<String, dynamic>{
        'urls': <String>[
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
        ],
      });
    }

    final turnUrls = _splitCsv(_turnUrlsEnv);
    if (turnUrls.isNotEmpty &&
        _turnUsernameEnv.trim().isNotEmpty &&
        _turnCredentialEnv.trim().isNotEmpty) {
      iceServers.add(<String, dynamic>{
        'urls': turnUrls,
        'username': _turnUsernameEnv.trim(),
        'credential': _turnCredentialEnv.trim(),
      });
    }

    return <String, dynamic>{
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
    };
  }

  List<String> _splitCsv(String raw) {
    if (raw.trim().isEmpty) {
      return const <String>[];
    }
    final out = <String>[];
    for (final item in raw.split(',')) {
      final value = item.trim();
      if (value.isNotEmpty && !out.contains(value)) {
        out.add(value);
      }
    }
    return out;
  }

  @override
  void dispose() {
    _endCall(localOnly: true);
    _socket?.dispose();
    _socket = null;
    _messageController.dispose();
    _listController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Socket Chat + WebRTC'),
            Text(
              _socketConnected ? 'Connecte' : 'Deconnecte',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Demarrer appel video',
            onPressed: _inCall ? null : _startCall,
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: const Color(0xFFE2E8F0),
                child: Text(
                  'Serveur: $_serverUrl\nRoom: $_roomId · User: $_username ($_userId)${_socketError == null ? '' : '\nErreur: $_socketError'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _listController,
                  itemCount: _messages.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    if (message.isSystem) {
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      );
                    }
                    return Align(
                      alignment: message.isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: message.isMine
                              ? const Color(0xFF1D4ED8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: message.isMine
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isMine
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ecrire un message',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_inCall)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _remoteConnected
                          ? RTCVideoView(
                              _remoteRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            )
                          : const Center(
                              child: Text(
                                'Connexion appel...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 12,
                      width: 110,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: const Color(0xFF0F172A),
                          child: RTCVideoView(
                            _localRenderer,
                            mirror: true,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 22,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            heroTag: 'mute',
                            backgroundColor: _audioEnabled
                                ? const Color(0xFF334155)
                                : const Color(0xFFB91C1C),
                            onPressed: _toggleAudio,
                            child: Icon(
                              _audioEnabled ? Icons.mic : Icons.mic_off,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton(
                            heroTag: 'camera',
                            backgroundColor: _cameraEnabled
                                ? const Color(0xFF334155)
                                : const Color(0xFFB91C1C),
                            onPressed: _toggleCamera,
                            child: Icon(
                              _cameraEnabled
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton(
                            heroTag: 'switch',
                            backgroundColor: const Color(0xFF334155),
                            onPressed: _switchCamera,
                            child: const Icon(Icons.cameraswitch),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton(
                            heroTag: 'hangup',
                            backgroundColor: const Color(0xFFDC2626),
                            onPressed: _endCall,
                            child: const Icon(Icons.call_end),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SocketChatMessage {
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isMine;
  final bool isSystem;

  const _SocketChatMessage({
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.isSystem = false,
  });
}
