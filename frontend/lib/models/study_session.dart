import 'package:flutter/material.dart';

enum TipoEstudo {
  questoes,
  pdf,
}

typedef StudyType = TipoEstudo;

TipoEstudo tipoEstudoAPartirDeTexto(String? textoTipo) {
  if (textoTipo == 'PDF') return TipoEstudo.pdf;
  return TipoEstudo.questoes;
}

TipoEstudo studyTypeFromString(String? type) => tipoEstudoAPartirDeTexto(type);

String tipoEstudoParaTexto(TipoEstudo tipo) {
  switch (tipo) {
    case TipoEstudo.questoes:
      return 'QUESTIONS';
    case TipoEstudo.pdf:
      return 'PDF';
  }
}

String studyTypeToString(TipoEstudo type) => tipoEstudoParaTexto(type);

class StudySession {
  final int id;
  final int idDisciplina;
  final String nomeDisciplina;
  final String corHexDisciplina;
  final TipoEstudo tipoEstudo;
  final int duracaoSegundos;
  final DateTime dataSessao;
  final String? topico;
  final String? anotacoes;

  // Específico para questões
  final int? totalQuestoes;
  final int? questoesCorretas;
  final double? taxaAcerto;

  // Específico para PDF
  final String? tituloMaterial;
  final int? paginaParada;
  final int? quantidadePaginasLidas;

  final DateTime criadoEm;

  StudySession({
    required this.id,
    required this.idDisciplina,
    required this.nomeDisciplina,
    required this.corHexDisciplina,
    required this.tipoEstudo,
    required this.duracaoSegundos,
    required this.dataSessao,
    this.topico,
    this.anotacoes,
    this.totalQuestoes,
    this.questoesCorretas,
    this.taxaAcerto,
    this.tituloMaterial,
    this.paginaParada,
    this.quantidadePaginasLidas,
    required this.criadoEm,
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
    final horas = duracaoSegundos ~/ 3600;
    final minutos = (duracaoSegundos % 3600) ~/ 60;
    final segundos = duracaoSegundos % 60;

    if (horas > 0) {
      return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
    } else if (minutos > 0) {
      return '${minutos}min ${segundos.toString().padLeft(2, '0')}s';
    } else {
      return '${segundos}s';
    }
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as int,
      idDisciplina: json['subjectId'] as int,
      nomeDisciplina: json['subjectName'] as String? ?? 'Disciplina',
      corHexDisciplina: json['subjectColor'] as String? ?? '#4F46E5',
      tipoEstudo: tipoEstudoAPartirDeTexto(json['studyType'] as String?),
      duracaoSegundos: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      dataSessao: json['sessionDate'] != null
          ? DateTime.parse(json['sessionDate'].toString())
          : DateTime.now(),
      topico: json['topic'] as String?,
      anotacoes: json['notes'] as String?,
      totalQuestoes: (json['totalQuestions'] as num?)?.toInt(),
      questoesCorretas: (json['correctQuestions'] as num?)?.toInt(),
      taxaAcerto: (json['accuracyRate'] as num?)?.toDouble(),
      tituloMaterial: json['materialTitle'] as String?,
      paginaParada: (json['pageStopped'] as num?)?.toInt(),
      quantidadePaginasLidas: (json['pagesReadCount'] as num?)?.toInt(),
      criadoEm: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'subjectId': idDisciplina,
      'studyType': tipoEstudoParaTexto(tipoEstudo),
      'durationSeconds': duracaoSegundos,
      'topic': topico,
      'notes': anotacoes,
      'sessionDate': dataSessao.toIso8601String(),
      'totalQuestions': tipoEstudo == TipoEstudo.questoes ? totalQuestoes : null,
      'correctQuestions':
          tipoEstudo == TipoEstudo.questoes ? questoesCorretas : null,
      'materialTitle': tipoEstudo == TipoEstudo.pdf ? tituloMaterial : null,
      'pageStopped': tipoEstudo == TipoEstudo.pdf ? paginaParada : null,
      'pagesReadCount': tipoEstudo == TipoEstudo.pdf ? quantidadePaginasLidas : null,
    };
  }
}
