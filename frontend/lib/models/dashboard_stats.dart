import 'package:flutter/material.dart';
import 'package:frontend/models/study_session.dart';

class SubjectMetric {
  final int idDisciplina;
  final String nomeDisciplina;
  final String corHexDisciplina;
  final int totalSegundosEstudo;
  final int totalQuestoes;
  final int totalAcertos;
  final double taxaAcerto;
  final int totalPaginasLidas;
  final int quantidadeSessoes;

  SubjectMetric({
    required this.idDisciplina,
    required this.nomeDisciplina,
    required this.corHexDisciplina,
    required this.totalSegundosEstudo,
    required this.totalQuestoes,
    required this.totalAcertos,
    required this.taxaAcerto,
    required this.totalPaginasLidas,
    required this.quantidadeSessoes,
  });

  Color get corDisciplina {
    try {
      final codigoHexLimpo = corHexDisciplina.replaceAll('#', '');
      if (codigoHexLimpo.length == 6) {
        return Color(int.parse('FF$codigoHexLimpo', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF4F46E5);
  }

  String get duracaoFormatada {
    final horas = totalSegundosEstudo ~/ 3600;
    final minutos = (totalSegundosEstudo % 3600) ~/ 60;
    if (horas > 0) {
      return '${horas}h ${minutos}m';
    }
    return '${minutos}m';
  }

  factory SubjectMetric.fromJson(Map<String, dynamic> json) {
    return SubjectMetric(
      idDisciplina: json['subjectId'] as int,
      nomeDisciplina: json['subjectName'] as String? ?? '',
      corHexDisciplina: json['subjectColor'] as String? ?? '#4F46E5',
      totalSegundosEstudo: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      totalQuestoes: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalAcertos: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      taxaAcerto: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      totalPaginasLidas: (json['totalPagesRead'] as num?)?.toInt() ?? 0,
      quantidadeSessoes: (json['sessionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardStats {
  final int totalSegundosEstudo;
  final int totalSessoes;
  final int totalQuestoes;
  final int totalAcertos;
  final double taxaAcertoGeral;
  final int totalPaginasLidas;
  final List<SubjectMetric> metricasDisciplinas;
  final List<StudySession> sessoesRecentes;

  DashboardStats({
    required this.totalSegundosEstudo,
    required this.totalSessoes,
    required this.totalQuestoes,
    required this.totalAcertos,
    required this.taxaAcertoGeral,
    required this.totalPaginasLidas,
    required this.metricasDisciplinas,
    required this.sessoesRecentes,
  });

  String get tempoTotalFormatado {
    final horas = totalSegundosEstudo ~/ 3600;
    final minutos = (totalSegundosEstudo % 3600) ~/ 60;
    return '${horas}h ${minutos.toString().padLeft(2, '0')}m';
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSegundosEstudo: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      totalSessoes: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalQuestoes: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalAcertos: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      taxaAcertoGeral:
          (json['overallAccuracyRate'] as num?)?.toDouble() ?? 0.0,
      totalPaginasLidas: (json['totalPagesRead'] as num?)?.toInt() ?? 0,
      metricasDisciplinas: (json['subjectMetrics'] as List<dynamic>? ?? [])
          .map((item) => SubjectMetric.fromJson(item as Map<String, dynamic>))
          .toList(),
      sessoesRecentes: (json['recentSessions'] as List<dynamic>? ?? [])
          .map((item) => StudySession.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
