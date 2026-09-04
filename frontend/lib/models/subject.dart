import 'package:flutter/material.dart';

class Subject {
  final int id;
  final String name;
  final String colorHex;
  final int cycleOrder;
  final bool active;
  final int targetMinutes;
  final int? groupId;
  final String? groupName;
  final int totalSessions;
  final int totalStudySeconds;
  final DateTime? lastStudiedAt;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.cycleOrder,
    required this.active,
    required this.targetMinutes,
    this.groupId,
    this.groupName,
    this.totalSessions = 0,
    this.totalStudySeconds = 0,
    this.lastStudiedAt,
    required this.createdAt,
  });

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF4F46E5);
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      colorHex: json['color'] as String? ?? '#4F46E5',
      cycleOrder: json['cycleOrder'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
      targetMinutes: json['targetMinutes'] as int? ?? 60,
      groupId: (json['groupId'] as num?)?.toInt(),
      groupName: json['groupName'] as String?,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalStudySeconds: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.tryParse(json['lastStudiedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': colorHex,
      'cycleOrder': cycleOrder,
      'active': active,
      'targetMinutes': targetMinutes,
      'groupId': groupId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
