import 'package:flutter/material.dart';
import 'package:frontend/models/study_session.dart';

class SubjectMetric {
  final int subjectId;
  final String subjectName;
  final String subjectColorHex;
  final int totalStudySeconds;
  final int totalQuestions;
  final int totalCorrect;
  final double accuracyRate;
  final int totalPagesRead;
  final int sessionCount;

  SubjectMetric({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColorHex,
    required this.totalStudySeconds,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.accuracyRate,
    required this.totalPagesRead,
    required this.sessionCount,
  });

  Color get subjectColor {
    try {
      final hex = subjectColorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF4F46E5);
  }

  String get formattedDuration {
    final hours = totalStudySeconds ~/ 3600;
    final minutes = (totalStudySeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  factory SubjectMetric.fromJson(Map<String, dynamic> json) {
    return SubjectMetric(
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String? ?? '',
      subjectColorHex: json['subjectColor'] as String? ?? '#4F46E5',
      totalStudySeconds: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      totalPagesRead: (json['totalPagesRead'] as num?)?.toInt() ?? 0,
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardStats {
  final int totalStudySeconds;
  final int totalSessions;
  final int totalQuestions;
  final int totalCorrect;
  final double overallAccuracyRate;
  final int totalPagesRead;
  final List<SubjectMetric> subjectMetrics;
  final List<StudySession> recentSessions;

  DashboardStats({
    required this.totalStudySeconds,
    required this.totalSessions,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.overallAccuracyRate,
    required this.totalPagesRead,
    required this.subjectMetrics,
    required this.recentSessions,
  });

  String get formattedTotalTime {
    final hours = totalStudySeconds ~/ 3600;
    final minutes = (totalStudySeconds % 3600) ~/ 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudySeconds: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      overallAccuracyRate:
          (json['overallAccuracyRate'] as num?)?.toDouble() ?? 0.0,
      totalPagesRead: (json['totalPagesRead'] as num?)?.toInt() ?? 0,
      subjectMetrics: (json['subjectMetrics'] as List<dynamic>? ?? [])
          .map((m) => SubjectMetric.fromJson(m as Map<String, dynamic>))
          .toList(),
      recentSessions: (json['recentSessions'] as List<dynamic>? ?? [])
          .map((s) => StudySession.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
