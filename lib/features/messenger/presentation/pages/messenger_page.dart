import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class _Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? avatarInitials;

  const _Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.avatarInitials,
  });
}

class _ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime time;
  final bool isMe;

  const _ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.time,
    this.isMe = false,
  });
}

class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  String? _activeConversationId;
  final _messageController = TextEditingController();
  final _timeFormat = DateFormat('HH:mm');
  final _dateFormat = DateFormat('dd/MM');

  final _conversations = <_Conversation>[
    _Conversation(id: '1', name: 'Équipe Élevage', lastMessage: 'La truie T-003 montre des signes de chaleur', lastMessageTime: DateTime(2026, 4, 1, 9, 15), unreadCount: 3, isOnline: true, avatarInitials: 'EE'),
    _Conversation(id: '2', name: 'Dr Rakoto', lastMessage: 'Vaccination prévue demain à 8h', lastMessageTime: DateTime(2026, 4, 1, 8, 30), isOnline: true, avatarInitials: 'DR'),
    _Conversation(id: '3', name: 'Fournisseur Aliment', lastMessage: 'Livraison confirmée pour vendredi', lastMessageTime: DateTime(2026, 3, 31, 16, 45), avatarInitials: 'FA'),
    _Conversation(id: '4', name: 'Jean Inséminateur', lastMessage: 'IA réalisée sur T-001 ce matin', lastMessageTime: DateTime(2026, 3, 31, 10, 20), isOnline: false, avatarInitials: 'JI'),
  ];

  final _messages = <String, List<_ChatMessage>>{
    '1': [
      _ChatMessage(id: 'm1', senderId: 'u2', senderName: 'Paul', text: 'Bonjour, la truie T-003 montre des signes de chaleur depuis ce matin.', time: DateTime(2026, 4, 1, 8, 45)),
      _ChatMessage(id: 'm2', senderId: 'u1', senderName: 'Moi', text: 'Merci Paul. On prépare l\'IA pour demain matin ?', time: DateTime(2026, 4, 1, 8, 50), isMe: true),
      _ChatMessage(id: 'm3', senderId: 'u3', senderName: 'Marie', text: 'Je peux préparer la dose de V-001 ce soir.', time: DateTime(2026, 4, 1, 9, 10)),
      _ChatMessage(id: 'm4', senderId: 'u2', senderName: 'Paul', text: 'La truie T-003 montre des signes de chaleur', time: DateTime(2026, 4, 1, 9, 15)),
    ],
    '2': [
      _ChatMessage(id: 'm5', senderId: 'u4', senderName: 'Dr Rakoto', text: 'Les résultats du contrôle sanitaire sont bons.', time: DateTime(2026, 4, 1, 8, 0)),
      _ChatMessage(id: 'm6', senderId: 'u1', senderName: 'Moi', text: 'Super ! Quand est prévue la prochaine vaccination ?', time: DateTime(2026, 4, 1, 8, 15), isMe: true),
      _ChatMessage(id: 'm7', senderId: 'u4', senderName: 'Dr Rakoto', text: 'Vaccination prévue demain à 8h', time: DateTime(2026, 4, 1, 8, 30)),
    ],
  };

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth > 700;
            if (isWide) {
              return Row(
                children: [
                  SizedBox(width: 320, child: _buildConversationList()),
                  const VerticalDivider(width: 1, color: AppColors.borderLight),
                  Expanded(
                    child: _activeConversationId != null
                        ? _buildChatView()
                        : _buildEmptyChat(),
                  ),
                ],
              );
            }
            if (_activeConversationId != null) {
              return _buildChatView(showBack: true);
            }
            return _buildConversationList();
          },
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text('${_conversations.length} conversation(s)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _conversations.length,
            itemBuilder: (_, i) => _buildConversationTile(_conversations[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildConversationTile(_Conversation conv) {
    final isActive = _activeConversationId == conv.id;
    return Material(
      color: isActive ? AppColors.primaryPale : Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _activeConversationId = conv.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderLight.withAlpha(80)))),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withAlpha(20),
                    child: Text(conv.avatarInitials ?? conv.name[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                  ),
                  if (conv.isOnline)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(conv.name, style: TextStyle(fontWeight: conv.unreadCount > 0 ? FontWeight.w900 : FontWeight.w700, fontSize: 14, color: AppColors.textPrimary))),
                      Text(_dateFormat.format(conv.lastMessageTime), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(child: Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textMuted, fontWeight: conv.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500))),
                      if (conv.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                          child: Text('${conv.unreadCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatView({bool showBack = false}) {
    final conv = _conversations.where((c) => c.id == _activeConversationId).firstOrNull;
    if (conv == null) return _buildEmptyChat();
    final messages = _messages[conv.id] ?? [];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.chatHeader, AppColors.chatHeaderSoft],
            ),
          ),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 20),
                  onPressed: () => setState(() => _activeConversationId = null),
                ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withAlpha(30),
                child: Text(conv.avatarInitials ?? conv.name[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                  if (conv.isOnline) Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('En ligne', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              )),
              IconButton(icon: const Icon(LucideIcons.phone, size: 20, color: Colors.white70), onPressed: () {}),
              IconButton(icon: const Icon(LucideIcons.video, size: 20, color: Colors.white70), onPressed: () {}),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.chatBackgroundTop, AppColors.chatBackgroundBottom],
              ),
            ),
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[messages.length - 1 - i];
                return _buildMessageBubble(msg);
              },
            ),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: AppSpacing.s10),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.chatOutgoingBubble : AppColors.chatIncomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
          border: Border.all(color: msg.isMe ? AppColors.primaryLight.withAlpha(80) : AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isMe) Text(msg.senderName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
            Text(msg.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(_timeFormat.format(msg.time), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
      decoration: BoxDecoration(color: AppColors.chatInputSurface, border: const Border(top: BorderSide(color: AppColors.borderLight))),
      child: Row(
        children: [
          IconButton(icon: const Icon(LucideIcons.paperclip, size: 20, color: AppColors.textMuted), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(999)),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Message...', hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
            child: IconButton(icon: const Icon(LucideIcons.send, size: 18, color: Colors.white), onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surfaceContainer, shape: BoxShape.circle),
            child: const Icon(LucideIcons.messageSquare, size: 40, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.s16),
          const Text('Sélectionnez une conversation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
