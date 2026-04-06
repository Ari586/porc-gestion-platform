import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';

import '../../../../core/providers/session_provider.dart';
import '../../data/chat_persistence_service.dart';

// --- Modèles Restaurés ---

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final List<String> readByUserIds;
  final String messageType;
  final String mediaBase64;
  final String mediaName;
  final String mediaMimeType;
  final int mediaSizeBytes;
  final String? audioPath;
  final int? audioDuration;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.readByUserIds = const [],
    this.messageType = 'text',
    this.mediaBase64 = '',
    this.mediaName = '',
    this.mediaMimeType = '',
    this.mediaSizeBytes = 0,
    this.audioPath,
    this.audioDuration,
  });
}

class ChatConversationSummary {
  final String id;
  final String title;
  final String subtitle;
  final String preview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String avatarLabel;
  final Color avatarColor;
  final bool isGroup;

  const ChatConversationSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.avatarLabel,
    required this.avatarColor,
    this.isGroup = false,
  });
}

// --- Page Messenger Restaurée ---

class MessengerPage extends ConsumerStatefulWidget {
  const MessengerPage({super.key});

  @override
  ConsumerState<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends ConsumerState<MessengerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _chatComposerController = TextEditingController();
  final TextEditingController _messengerSearchController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _activeChatConversationId = 'thread-public-1';
  bool _isMobileMessengerThreadOpen = false;
  String _messengerConversationFilter = '';

  // Socket & WebRTC State
  io.Socket? _socket;
  bool _socketConnected = false;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  // Audio Recording
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Functional Services
  final ChatPersistenceService _persistenceService = ChatPersistenceService();
  
  // Constants (Restored)
  static const int _chatImageMaxBytes = 320 * 1024;
  static const int _chatAudioMaxBytes = 600 * 1024;
  static const int _chatVideoMaxBytes = 900 * 1024;
  static const int _messageLimit = 2500;

  // Mock Conversations (Basées sur l'ancien design)
  final List<ChatConversationSummary> _conversations = [
    const ChatConversationSummary(
      id: 'thread-public-1',
      title: 'Équipe Élevage',
      subtitle: 'Conversation générale',
      preview: 'Connecté au serveur en temps réel',
      lastMessageAt: null,
      unreadCount: 0,
      avatarLabel: 'EE',
      avatarColor: Color(0xFF0F766E),
      isGroup: true,
    ),
    ChatConversationSummary(
      id: 'thread-dr-rakoto',
      title: 'Dr Rakoto',
      subtitle: 'Vétérinaire conseil',
      preview: 'Vaccination prévue demain à 8h',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 1,
      avatarLabel: 'DR',
      avatarColor: const Color(0xFF1D4ED8),
    ),
  ];

  final Map<String, List<ChatMessage>> _messagesByThread = {
    'thread-public-1': [],
    'thread-dr-rakoto': [],
  };

  @override
  void initState() {
    super.initState();
    // Pre-initialize empty thread lists for known threads
    for (var conv in _conversations) {
      _messagesByThread[conv.id] = [];
    }
    _loadPersistedMessages();
    _initializeWebRTC();
    _connectSocket();
  }

  Future<void> _loadPersistedMessages() async {
    try {
      final messages = await _persistenceService.loadMessages();
      if (messages.isNotEmpty && mounted) {
        setState(() {
          for (var msg in messages) {
            _messagesByThread.putIfAbsent(msg.conversationId, () => []);
            _messagesByThread[msg.conversationId]!.add(msg);
          }
        });
        debugPrint('Loaded ${messages.length} messages from persistence');
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Persistence failure: $e');
    }
  }

  Future<void> _initializeWebRTC() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {
    _socket = io.io(
      'https://porc-socket-signaling-520994990737.us-central1.run.app',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    _socket?.onConnect((_) {
      if (mounted) setState(() => _socketConnected = true);
      _socket?.emit('join_room', _activeChatConversationId);
    });

    _socket?.onReceiveMessage((data) {
      if (mounted) {
        final msg = ChatMessage(
          id: DateTime.now().toIso8601String(),
          conversationId: _activeChatConversationId,
          senderId: data['senderId'] ?? 'unknown',
          senderName: data['senderName'] ?? 'Utilisateur',
          text: data['text'] ?? '',
          sentAt: DateTime.now(),
        );
        setState(() {
          _messagesByThread.putIfAbsent(_activeChatConversationId, () => []);
          final threadMessages = _messagesByThread[_activeChatConversationId]!;
          threadMessages.add(msg);
          if (threadMessages.length > _messageLimit) {
            threadMessages.removeRange(0, threadMessages.length - _messageLimit);
          }
        });
        _persistenceService.saveMessages(_messagesByThread.values.expand((x) => x).toList());
        _scrollToBottom();
      }
    });

    _socket?.onDisconnect((_) {
      if (mounted) setState(() => _socketConnected = false);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _socket?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _chatComposerController.dispose();
    _messengerSearchController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // --- Widgets Restaurés ---

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: _buildMessengerHub(isMobile),
    );
  }

  Widget _buildMessengerHub(bool mobile) {
    if (mobile && _isMobileMessengerThreadOpen) {
      return _buildMessengerThread(mobile: true);
    }

    return Row(
      children: [
        // Liste des Conversations
        SizedBox(
          width: mobile ? double.infinity : 350,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                _buildMessengerHeader(),
                _buildMessengerConversationSearchField(),
                Expanded(child: _buildMessengerConversationList(mobile)),
              ],
            ),
          ),
        ),
        // Thread (Desktop)
        if (!mobile)
          Expanded(
            child: _activeChatConversationId.isEmpty
                ? _buildMessengerEmptyState()
                : _buildMessengerThread(mobile: false),
          ),
      ],
    );
  }

  Widget _buildMessengerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _socketConnected ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _socketConnected ? 'Connecté' : 'Hors ligne',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerConversationSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _messengerSearchController,
        onChanged: (val) => setState(() => _messengerConversationFilter = val),
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildMessengerConversationList(bool mobile) {
    final filtered = _conversations.where((c) =>
        c.title.toLowerCase().contains(_messengerConversationFilter.toLowerCase())).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final conv = filtered[index];
        final isActive = _activeChatConversationId == conv.id;

        return _buildMessengerConversationTile(conv, isActive, mobile);
      },
    );
  }

  Widget _buildMessengerConversationTile(
      ChatConversationSummary conv, bool isActive, bool mobile) {
    return InkWell(
      onTap: () {
        setState(() {
          _activeChatConversationId = conv.id;
          if (mobile) _isMobileMessengerThreadOpen = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF1F5F9) : Colors.transparent,
          border: isActive
              ? const Border(left: BorderSide(color: Color(0xFF0F766E), width: 4))
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: conv.avatarColor,
              child: Text(
                conv.avatarLabel,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conv.title,
                        style: TextStyle(
                          fontWeight: conv.unreadCount > 0 ? FontWeight.w800 : FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (conv.lastMessageAt != null)
                        Text(
                          DateFormat('HH:mm').format(conv.lastMessageAt!),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conv.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: conv.unreadCount > 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (conv.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF0F766E), shape: BoxShape.circle),
                child: Text(
                  '${conv.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessengerEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text(
            'Sélectionnez une conversation',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerThread({required bool mobile}) {
    final activeConv = _conversations.firstWhere((c) => c.id == _activeChatConversationId);
    final messages = _messagesByThread[_activeChatConversationId] ?? [];

    return Column(
      children: [
        // Thread Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              if (mobile)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _isMobileMessengerThreadOpen = false),
                ),
              CircleAvatar(
                radius: 18,
                backgroundColor: activeConv.avatarColor,
                child: Text(activeConv.avatarLabel, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeConv.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      activeConv.subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: Color(0xFF64748B)),
                onPressed: () => _startCall(activeConv, false),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_outlined, color: Color(0xFF64748B)),
                onPressed: () => _startCall(activeConv, true),
              ),
            ],
          ),
        ),
        // Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == ref.read(sessionProvider)?.id;
              return _buildMessageBubble(msg, isMe);
            },
          ),
        ),
        // Composer
        _buildMessageComposer(mobile),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF0F766E) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg.senderName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                ),
              ),
            Text(
              msg.text,
              style: TextStyle(color: isMe ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(msg.sentAt),
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(bool mobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF64748B)),
            onPressed: () => _openMessengerAttachmentSheet(_activeChatConversationId),
          ),
          Expanded(
            child: TextField(
              controller: _chatComposerController,
              decoration: InputDecoration(
                hintText: 'Écrire un message...',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _sendChatMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0F766E), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendChatMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSendChatAttachment(String conversationId, String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type == 'image' ? FileType.image : (type == 'video' ? FileType.video : FileType.any),
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      int maxBytes = _chatImageMaxBytes;
      if (type == 'video') maxBytes = _chatVideoMaxBytes;
      if (type == 'audio') maxBytes = _chatAudioMaxBytes;

      if (file.size > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fichier trop lourd. Limite pour $type : ${maxBytes ~/ 1024} KB')),
          );
        }
        return;
      }

      // Envoi simulé pour la restauration
      _sendChatMessage(customText: '📎 Envoyé $type : ${file.name}');
    }
  }

  void _sendChatMessage({String? customText}) {
    final text = customText ?? _chatComposerController.text.trim();
    if (text.isEmpty) return;
    
    final activeConv = _conversations.firstWhere((c) => c.id == _activeChatConversationId);
    final user = ref.read(sessionProvider);
    final msg = ChatMessage(
      id: DateTime.now().toIso8601String(),
      conversationId: _activeChatConversationId,
      senderId: user?.id ?? 'me',
      senderName: user?.name ?? 'Moi',
      text: text,
      sentAt: DateTime.now(),
    );

    _socket?.emit('send_message', {
      'roomId': _activeChatConversationId,
      'senderId': user?.id,
      'senderName': user?.name,
      'text': text,
    });

    setState(() {
      _messagesByThread.putIfAbsent(_activeChatConversationId, () => []);
      final threadMessages = _messagesByThread[_activeChatConversationId]!;
      threadMessages.add(msg);
      if (threadMessages.length > _messageLimit) {
        threadMessages.removeRange(0, threadMessages.length - _messageLimit);
      }
    });

    // Save ALL messages across ALL threads to ensure global persistence
    final allMessages = _messagesByThread.values.expand((x) => x).toList();
    _persistenceService.saveMessages(allMessages).then((_) {
      debugPrint('Saved ${allMessages.length} messages globally');
    });
    
    // Audit Log Restoration
    _addAuditLog(
      module: 'MESSAGERIE',
      action: 'SEND_MESSAGE',
      detail: 'Message envoyé dans ${activeConv.title}',
    );

    _chatComposerController.clear();
    _scrollToBottom();
  }

  void _addAuditLog({
    required String module,
    required String action,
    required String detail,
  }) {
    final user = ref.read(sessionProvider);
    // In a real app, this would call a global Audit service or provider.
    // For restoration, we ensure it's called to trace activity.
    debugPrint('[AUDIT] $module | $action | $detail by ${user?.name}');
  }

  void _startCall(ChatConversationSummary conv, bool video) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appel ${video ? "vidéo" : "vocal"} vers ${conv.title} (Simulé)')),
      );
    }
  }

  void _openMessengerAttachmentSheet(String conversationId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image (Max 320 KB)'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendChatAttachment(conversationId, 'image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Vidéo (Max 900 KB)'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendChatAttachment(conversationId, 'video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Audio (Max 600 KB)'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendChatAttachment(conversationId, 'audio');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Extensions & Helpers ---
extension SocketExtension on io.Socket {
  void onReceiveMessage(Function(dynamic) handler) {
    on('receive_message', (data) => handler(data));
  }
}
