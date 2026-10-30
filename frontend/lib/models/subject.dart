import 'package:flutter/material.dart';

class Subject {
  final int id;
  final String nome;
  final String corHex;
  final int ordemCiclo;
  final bool ativo;
  final int metaMinutos;
  final int? idGrupo;
  final String? nomeGrupo;
  final int totalSessoes;
  final int totalSegundosEstudo;
  final DateTime? ultimoEstudoEm;
  final DateTime criadoEm;

  Subject({
    required this.id,
    required this.nome,
    required this.corHex,
    required this.ordemCiclo,
    required this.ativo,
    required this.metaMinutos,
    this.idGrupo,
    this.nomeGrupo,
    this.totalSessoes = 0,
    this.totalSegundosEstudo = 0,
    this.ultimoEstudoEm,
    required this.criadoEm,
  });

  Color get cor {
    try {
      final codigoHexLimpo = corHex.replaceAll('#', '');
      if (codigoHexLimpo.length == 6) {
        return Color(int.parse('FF$codigoHexLimpo', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF4F46E5);
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      nome: json['name'] as String? ?? '',
      corHex: json['color'] as String? ?? '#4F46E5',
      ordemCiclo: json['cycleOrder'] as int? ?? 0,
      ativo: json['active'] as bool? ?? true,
      metaMinutos: json['targetMinutes'] as int? ?? 60,
      idGrupo: (json['groupId'] as num?)?.toInt(),
      nomeGrupo: json['groupName'] as String?,
      totalSessoes: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalSegundosEstudo: (json['totalStudySeconds'] as num?)?.toInt() ?? 0,
      ultimoEstudoEm: json['lastStudiedAt'] != null
          ? DateTime.tryParse(json['lastStudiedAt'].toString())
          : null,
      criadoEm: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nome,
      'color': corHex,
      'cycleOrder': ordemCiclo,
      'active': ativo,
      'targetMinutes': metaMinutos,
      'groupId': idGrupo,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
