import 'json_helpers.dart';

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String actorCode;
  final String actorName;
  final String module;
  final String action;
  final String detail;
  final String severity;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.actorCode,
    required this.actorName,
    required this.module,
    required this.action,
    required this.detail,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'actorCode': actorCode,
      'actorName': actorName,
      'module': module,
      'action': action,
      'detail': detail,
      'severity': severity,
    };
  }

  static AuditLogEntry? fromJson(Map<String, dynamic> json) {
    final id = JsonHelpers.readString(json['id']).trim();
    final timestamp = JsonHelpers.parseDateTime(JsonHelpers.readString(json['timestamp']));
    final actorCode = JsonHelpers.readString(json['actorCode']).trim();
    final actorName = JsonHelpers.readString(json['actorName']).trim();
    final module = JsonHelpers.readString(json['module']).trim();
    final action = JsonHelpers.readString(json['action']).trim();
    final detail = JsonHelpers.readString(json['detail']).trim();
    final severity = JsonHelpers.readString(json['severity']).trim();
    if (id.isEmpty || timestamp == null || actorCode.isEmpty || actorName.isEmpty || module.isEmpty || action.isEmpty || severity.isEmpty) {
      return null;
    }
    return AuditLogEntry(
      id: id,
      timestamp: timestamp,
      actorCode: actorCode,
      actorName: actorName,
      module: module,
      action: action,
      detail: detail,
      severity: severity,
    );
  }
}
