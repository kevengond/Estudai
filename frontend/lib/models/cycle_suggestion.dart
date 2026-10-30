import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';

class NextStudySuggestion {
  final Subject? disciplinaSugerida;
  final StudySession? ultimaSessao;
  final TipoEstudo? tipoEstudoSugerido;
  final String mensagemRetomada;
  final String detalhePontoParada;
  final String statusCiclo;
  final bool ehRetomadaUltimoConteudo;
  final String? materialOuTopicoSugerido;
  final int? paginaSugerida;
  final int? loteQuestoesSugerido;

  NextStudySuggestion({
    this.disciplinaSugerida,
    this.ultimaSessao,
    this.tipoEstudoSugerido,
    required this.mensagemRetomada,
    required this.detalhePontoParada,
    required this.statusCiclo,
    required this.ehRetomadaUltimoConteudo,
    this.materialOuTopicoSugerido,
    this.paginaSugerida,
    this.loteQuestoesSugerido,
  });

  factory NextStudySuggestion.fromJson(Map<String, dynamic> json) {
    return NextStudySuggestion(
      disciplinaSugerida: json['suggestedSubject'] != null
          ? Subject.fromJson(json['suggestedSubject'] as Map<String, dynamic>)
          : null,
      ultimaSessao: json['lastSession'] != null
          ? StudySession.fromJson(json['lastSession'] as Map<String, dynamic>)
          : null,
      tipoEstudoSugerido: json['suggestionType'] != null
          ? tipoEstudoAPartirDeTexto(json['suggestionType'] as String?)
          : null,
      mensagemRetomada: json['resumeMessage'] as String? ?? '',
      detalhePontoParada: json['checkpointDetail'] as String? ?? '',
      statusCiclo: json['cycleStatus'] as String? ?? '',
      ehRetomadaUltimoConteudo: json['isResumeLastContent'] as bool? ?? false,
      materialOuTopicoSugerido: json['suggestedMaterialOrTopic'] as String?,
      paginaSugerida: (json['suggestedPage'] as num?)?.toInt(),
      loteQuestoesSugerido:
          (json['suggestedQuestionsBatch'] as num?)?.toInt(),
    );
  }
}
