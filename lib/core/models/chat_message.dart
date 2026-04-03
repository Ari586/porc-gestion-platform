import 'json_helpers.dart';

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
  final String callType;
  final String callStatus;
  final int callDurationSeconds;
  final String callSessionId;

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
    this.callType = '',
    this.callStatus = '',
    this.callDurationSeconds = 0,
    this.callSessionId = '',
  });

  ChatMessage copyWith({List<String>? readByUserIds}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: sentAt,
      readByUserIds: readByUserIds ?? this.readByUserIds,
      messageType: messageType,
      mediaBase64: mediaBase64,
      mediaName: mediaName,
      mediaMimeType: mediaMimeType,
      mediaSizeBytes: mediaSizeBytes,
      callType: callType,
      callStatus: callStatus,
      callDurationSeconds: callDurationSeconds,
      callSessionId: callSessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': sentAt.toUtc().toIso8601String(),
      'readByUserIds': readByUserIds,
      'messageType': messageType,
      'mediaBase64': mediaBase64,
      'mediaName': mediaName,
      'mediaMimeType': mediaMimeType,
      'mediaSizeBytes': mediaSizeBytes,
      'callType': callType,
      'callStatus': callStatus,
      'callDurationSeconds': callDurationSeconds,
      'callSessionId': callSessionId,
    };
  }

  static ChatMessage? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final conversationId = JsonHelpers.readString(json['conversationId']).trim();
    final senderId = JsonHelpers.readString(json['senderId']).trim();
    final senderName = JsonHelpers.readString(json['senderName']).trim();
    final text = JsonHelpers.readString(json['text']).trim();
    final sentAt = JsonHelpers.parseDateTime(JsonHelpers.readString(json['sentAt']));
    final messageType = JsonHelpers.readString(json['messageType']).trim().isEmpty
        ? 'text'
        : JsonHelpers.readString(json['messageType']).trim();
    final mediaBase64 = JsonHelpers.readString(json['mediaBase64']).trim();
    if (id.isEmpty || conversationId.isEmpty || senderId.isEmpty || senderName.isEmpty || sentAt == null) {
      return null;
    }
    final hasRenderableBody = text.isNotEmpty ||
        mediaBase64.isNotEmpty ||
        messageType == 'call' ||
        messageType == 'audio' ||
        messageType == 'video' ||
        messageType == 'image';
    if (!hasRenderableBody) return null;
    var readBy = JsonHelpers.readStringList(json['readByUserIds']);
    if (!readBy.contains(senderId)) {
      readBy = [...readBy, senderId];
    }
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: sentAt,
      readByUserIds: readBy,
      messageType: messageType,
      mediaBase64: mediaBase64,
      mediaName: JsonHelpers.readString(json['mediaName']).trim(),
      mediaMimeType: JsonHelpers.readString(json['mediaMimeType']).trim(),
      mediaSizeBytes: JsonHelpers.readInt(json['mediaSizeBytes']),
      callType: JsonHelpers.readString(json['callType']).trim(),
      callStatus: JsonHelpers.readString(json['callStatus']).trim(),
      callDurationSeconds: JsonHelpers.readInt(json['callDurationSeconds']),
      callSessionId: JsonHelpers.readString(json['callSessionId']).trim(),
    );
  }
}
