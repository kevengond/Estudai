import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';

class NextStudySuggestion {
  final Subject? suggestedSubject;
  final StudySession? lastSession;
  final StudyType? suggestionType;
  final String resumeMessage;
  final String checkpointDetail;
  final String cycleStatus;
  final bool isResumeLastContent;
  final String? suggestedMaterialOrTopic;
  final int? suggestedPage;
  final int? suggestedQuestionsBatch;

  NextStudySuggestion({
    this.suggestedSubject,
    this.lastSession,
    this.suggestionType,
    required this.resumeMessage,
    required this.checkpointDetail,
    required this.cycleStatus,
    required this.isResumeLastContent,
    this.suggestedMaterialOrTopic,
    this.suggestedPage,
    this.suggestedQuestionsBatch,
  });

  factory NextStudySuggestion.fromJson(Map<String, dynamic> json) {
    return NextStudySuggestion(
      suggestedSubject: json['suggestedSubject'] != null
          ? Subject.fromJson(json['suggestedSubject'] as Map<String, dynamic>)
          : null,
      lastSession: json['lastSession'] != null
          ? StudySession.fromJson(json['lastSession'] as Map<String, dynamic>)
          : null,
      suggestionType: json['suggestionType'] != null
          ? studyTypeFromString(json['suggestionType'] as String?)
          : null,
      resumeMessage: json['resumeMessage'] as String? ?? '',
      checkpointDetail: json['checkpointDetail'] as String? ?? '',
      cycleStatus: json['cycleStatus'] as String? ?? '',
      isResumeLastContent: json['isResumeLastContent'] as bool? ?? false,
      suggestedMaterialOrTopic: json['suggestedMaterialOrTopic'] as String?,
      suggestedPage: (json['suggestedPage'] as num?)?.toInt(),
      suggestedQuestionsBatch:
          (json['suggestedQuestionsBatch'] as num?)?.toInt(),
    );
  }
}
