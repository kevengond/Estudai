import 'package:flutter/material.dart';

class StudyGroup {
  final int id;
  final String name;
  final String? description;
  final String colorHex;
  final bool active;
  final int totalSubjects;
  final int totalSessions;
  final int totalStudySeconds;
  final DateTime createdAt;

  StudyGroup({
    required this.id,
    required this.name,
    this.description,
    required this.colorHex,
    required this.active,
    this.totalSubjects = 0,
    this.totalSessions = 0,
    this.totalStudySeconds = 0,
    required this.createdAt,
  });

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF6366F1);
  }

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      colorHex: json['color'] as String? ?? '#6366F1',
      active: json['active'] as bool? ?? true,
      totalSubjects: (json['totalSubjects'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalStudySeconds: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': colorHex,
      'active': active,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
