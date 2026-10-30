import 'package:flutter/material.dart';

class StudyGroup {
  final int id;
  final String nome;
  final String? descricao;
  final String corHex;
  final bool ativo;
  final int totalDisciplinas;
  final int totalSessoes;
  final int totalSegundosEstudo;
  final DateTime criadoEm;

  StudyGroup({
    required this.id,
    required this.nome,
    this.descricao,
    required this.corHex,
    required this.ativo,
    this.totalDisciplinas = 0,
    this.totalSessoes = 0,
    this.totalSegundosEstudo = 0,
    required this.criadoEm,
  });

  Color get cor {
    try {
      final codigoHexLimpo = corHex.replaceAll('#', '');
      if (codigoHexLimpo.length == 6) {
        return Color(int.parse('FF$codigoHexLimpo', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF6366F1);
  }

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as int,
      nome: json['name'] as String? ?? '',
      descricao: json['description'] as String?,
      corHex: json['color'] as String? ?? '#6366F1',
      ativo: json['active'] as bool? ?? true,
      totalDisciplinas: (json['totalSubjects'] as num?)?.toInt() ?? 0,
      totalSessoes: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalSegundosEstudo: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      criadoEm: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nome,
      'description': descricao,
      'color': corHex,
      'active': ativo,
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
