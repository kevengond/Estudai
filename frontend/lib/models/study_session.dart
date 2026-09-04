import 'package:flutter/material.dart';

enum StudyType {
  questions,
  pdf,
}

StudyType studyTypeFromString(String? type) {
  if (type == 'PDF') return StudyType.pdf;
  return StudyType.questions;
}

String studyTypeToString(StudyType type) {
  switch (type) {
    case StudyType.questions:
      return 'QUESTIONS';
    case StudyType.pdf:
      return 'PDF';
  }
}

class StudySession {
  final int id;
  final int subjectId;
  final String subjectName;
  final String subjectColorHex;
  final StudyType studyType;
  final int durationSeconds;
  final DateTime sessionDate;
  final String? topic;
  final String? notes;

  // Questions specific
  final int? totalQuestions;
  final int? correctQuestions;
  final double? accuracyRate;

  // PDF specific
  final String? materialTitle;
  final int? pageStopped;
  final int? pagesReadCount;

  final DateTime createdAt;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectColorHex,
    required this.studyType,
    required this.durationSeconds,
    required this.sessionDate,
    this.topic,
    this.notes,
    this.totalQuestions,
    this.correctQuestions,
    this.accuracyRate,
    this.materialTitle,
    this.pageStopped,
    this.pagesReadCount,
    required this.createdAt,
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
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as int,
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String? ?? 'Disciplina',
      subjectColorHex: json['subjectColor'] as String? ?? '#4F46E5',
      studyType: studyTypeFromString(json['studyType'] as String?),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      sessionDate: json['sessionDate'] != null
          ? DateTime.parse(json['sessionDate'].toString())
          : DateTime.now(),
      topic: json['topic'] as String?,
      notes: json['notes'] as String?,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt(),
      correctQuestions: (json['correctQuestions'] as num?)?.toInt(),
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble(),
      materialTitle: json['materialTitle'] as String?,
      pageStopped: (json['pageStopped'] as num?)?.toInt(),
      pagesReadCount: (json['pagesReadCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'subjectId': subjectId,
      'studyType': studyTypeToString(studyType),
      'durationSeconds': durationSeconds,
      'topic': topic,
      'notes': notes,
      'sessionDate': sessionDate.toIso8601String(),
      'totalQuestions': studyType == StudyType.questions ? totalQuestions : null,
      'correctQuestions':
          studyType == StudyType.questions ? correctQuestions : null,
      'materialTitle': studyType == StudyType.pdf ? materialTitle : null,
      'pageStopped': studyType == StudyType.pdf ? pageStopped : null,
      'pagesReadCount': studyType == StudyType.pdf ? pagesReadCount : null,
    };
  }
}
