import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/pages/messenger_page.dart';

class ChatPersistenceService {
  static const String _prefsChatMessagesKey = 'pigia_messenger_v1';
  static const int _messageLimit = 2500;

  Future<List<ChatMessage>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_prefsChatMessagesKey);
      if (encoded == null) return [];

      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded.map((item) => _chatMessageFromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
      return [];
    }
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Keep only the last 2500 messages (as per old requirement)
      List<ChatMessage> toSave = messages;
      if (toSave.length > _messageLimit) {
        toSave = toSave.sublist(toSave.length - _messageLimit);
      }

      final String encoded = jsonEncode(toSave.map((msg) => _chatMessageToJson(msg)).toList());
      await prefs.setString(_prefsChatMessagesKey, encoded);
    } catch (e) {
      debugPrint('Error saving chat messages: $e');
    }
  }

  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      messageType: json['messageType'] ?? 'text',
      mediaBase64: json['mediaBase64'] ?? '',
      mediaName: json['mediaName'] ?? '',
      mediaMimeType: json['mediaMimeType'] ?? '',
      mediaSizeBytes: json['mediaSizeBytes'] ?? 0,
      audioPath: json['audioPath'],
      audioDuration: json['audioDuration'],
    );
  }

  Map<String, dynamic> _chatMessageToJson(ChatMessage msg) {
    return {
      'id': msg.id,
      'conversationId': msg.conversationId,
      'senderId': msg.senderId,
      'senderName': msg.senderName,
      'text': msg.text,
      'sentAt': msg.sentAt.toIso8601String(),
      'messageType': msg.messageType,
      'mediaBase64': msg.mediaBase64,
      'mediaName': msg.mediaName,
      'mediaMimeType': msg.mediaMimeType,
      'mediaSizeBytes': msg.mediaSizeBytes,
      'audioPath': msg.audioPath,
      'audioDuration': msg.audioDuration,
    };
  }
}
