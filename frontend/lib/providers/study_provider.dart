import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/cycle_suggestion.dart';
import 'package:frontend/models/dashboard_stats.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/services/api_service.dart';

class StudyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  List<StudyGroup> _groups = [];
  StudyGroup? _selectedGroup;

  List<Subject> _subjects = [];
  NextStudySuggestion? _suggestion;
  DashboardStats? _dashboardStats;
  List<StudySession> _sessions = [];

  // Stopwatch / Timer State
  Timer? _timer;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;

  // Form State for Recording
  Subject? _selectedSubject;
  StudyType _selectedStudyType = StudyType.questions;
  String _topic = '';
  String _notes = '';

  // Questions mode state
  int _totalQuestions = 0;
  int _correctQuestions = 0;

  // PDF mode state
  String _materialTitle = '';
  int _pageStopped = 0;
  int _pagesReadCount = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<StudyGroup> get groups => _groups;
  StudyGroup? get selectedGroup => _selectedGroup;

  List<Subject> get subjects => _subjects;
  List<Subject> get activeSubjects => _subjects.where((s) => s.active).toList();
  NextStudySuggestion? get suggestion => _suggestion;
  DashboardStats? get dashboardStats => _dashboardStats;
  List<StudySession> get sessions => _sessions;

  int get timerSeconds => _timerSeconds;
  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;

  Subject? get selectedSubject => _selectedSubject;
  StudyType get selectedStudyType => _selectedStudyType;
  String get topic => _topic;
  String get notes => _notes;
  int get totalQuestions => _totalQuestions;
  int get correctQuestions => _correctQuestions;
  String get materialTitle => _materialTitle;
  int get pageStopped => _pageStopped;
  int get pagesReadCount => _pagesReadCount;

  double get currentAccuracyRate {
    if (_totalQuestions <= 0) return 0.0;
    return (_correctQuestions / _totalQuestions) * 100.0;
  }

  String get formattedTimer {
    final hours = _timerSeconds ~/ 3600;
    final minutes = (_timerSeconds % 3600) ~/ 60;
    final seconds = _timerSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Initialization & Data Fetching ---
  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchGroups();
      await Future.wait([
        fetchSubjects(),
        fetchSuggestion(),
        fetchDashboardStats(),
        fetchSessions(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroups() async {
    try {
      _groups = await ApiService.getGroups();
      if (_groups.isNotEmpty && _selectedGroup == null) {
        _selectedGroup = _groups.first;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectGroup(StudyGroup? group) {
    if (_selectedGroup?.id == group?.id) return;
    _selectedGroup = group;
    _selectedSubject = null;
    notifyListeners();
    refreshGroupData();
  }

  Future<void> refreshGroupData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchSubjects(),
        fetchSuggestion(),
        fetchDashboardStats(),
        fetchSessions(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubjects() async {
    try {
      _subjects = await ApiService.getSubjects(groupId: _selectedGroup?.id);
      if (_selectedSubject == null && _subjects.isNotEmpty) {
        _selectedSubject = _subjects.firstWhere((s) => s.active, orElse: () => _subjects.first);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSuggestion() async {
    try {
      _suggestion = await ApiService.getNextStudySuggestion(groupId: _selectedGroup?.id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      _dashboardStats = await ApiService.getDashboardStats(groupId: _selectedGroup?.id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSessions({int? subjectId}) async {
    try {
      _sessions = await ApiService.getSessions(subjectId: subjectId);
      if (_selectedGroup != null && subjectId == null) {
        final subIds = _subjects.map((s) => s.id).toSet();
        _sessions = _sessions.where((s) => subIds.contains(s.subjectId)).toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // --- Timer Controls ---
  void startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    if (!_isTimerRunning) return;
    _timer?.cancel();
    _isTimerRunning = false;
    _isTimerPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    if (_isTimerRunning) return;
    startTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    _timerSeconds = 0;
    _isTimerRunning = false;
    _isTimerPaused = false;
    notifyListeners();
  }

  void setManualDuration(int seconds) {
    _timerSeconds = seconds;
    notifyListeners();
  }

  // --- Form Setters ---
  void setSelectedSubject(Subject? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setSelectedStudyType(StudyType type) {
    _selectedStudyType = type;
    notifyListeners();
  }

  void setTopic(String val) {
    _topic = val;
    notifyListeners();
  }

  void setNotes(String val) {
    _notes = val;
    notifyListeners();
  }

  void setTotalQuestions(int val) {
    _totalQuestions = val;
    if (_correctQuestions > _totalQuestions) {
      _correctQuestions = _totalQuestions;
    }
    notifyListeners();
  }

  void setCorrectQuestions(int val) {
    _correctQuestions = val;
    notifyListeners();
  }

  void setMaterialTitle(String val) {
    _materialTitle = val;
    notifyListeners();
  }

  void setPageStopped(int val) {
    _pageStopped = val;
    notifyListeners();
  }

  void setPagesReadCount(int val) {
    _pagesReadCount = val;
    notifyListeners();
  }

  // --- Pre-fill from Suggestion ---
  void prepareFromSuggestion(NextStudySuggestion sugg) {
    if (sugg.suggestedSubject != null) {
      final match = _subjects.firstWhere(
        (s) => s.id == sugg.suggestedSubject!.id,
        orElse: () => sugg.suggestedSubject!,
      );
      _selectedSubject = match;
    }

    if (sugg.suggestionType != null) {
      _selectedStudyType = sugg.suggestionType!;
    }

    if (sugg.suggestionType == StudyType.pdf) {
      _materialTitle = sugg.suggestedMaterialOrTopic ?? '';
      _pageStopped = sugg.suggestedPage ?? 0;
      _pagesReadCount = 0;
    } else {
      _topic = sugg.suggestedMaterialOrTopic ?? '';
      _totalQuestions = sugg.suggestedQuestionsBatch ?? 20;
      _correctQuestions = 0;
    }

    resetTimer();
    notifyListeners();
  }

  // --- Save Session ---
  Future<bool> saveCurrentSession() async {
    if (_selectedSubject == null) {
      _errorMessage = 'Selecione uma disciplina para registrar o estudo.';
      notifyListeners();
      return false;
    }

    if (_timerSeconds <= 0) {
      _errorMessage = 'O tempo de estudo deve ser maior que zero.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'subjectId': _selectedSubject!.id,
        'studyType': studyTypeToString(_selectedStudyType),
        'durationSeconds': _timerSeconds,
        'topic': _topic.isNotEmpty ? _topic : null,
        'notes': _notes.isNotEmpty ? _notes : null,
        'sessionDate': DateTime.now().toIso8601String(),
        'totalQuestions': _selectedStudyType == StudyType.questions ? _totalQuestions : null,
        'correctQuestions': _selectedStudyType == StudyType.questions ? _correctQuestions : null,
        'materialTitle': _selectedStudyType == StudyType.pdf ? _materialTitle : null,
        'pageStopped': _selectedStudyType == StudyType.pdf ? _pageStopped : null,
        'pagesReadCount': _selectedStudyType == StudyType.pdf ? _pagesReadCount : null,
      };

      await ApiService.createSession(data);
      resetTimer();
      _topic = '';
      _notes = '';
      _totalQuestions = 0;
      _correctQuestions = 0;
      _materialTitle = '';
      _pageStopped = 0;
      _pagesReadCount = 0;

      await Future.wait([
        fetchGroups(),
        fetchSubjects(),
        fetchSuggestion(),
        fetchDashboardStats(),
        fetchSessions(),
      ]);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Study Group (Concurso) Management ---
  Future<bool> addGroup(String name, String? description, String colorHex) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGroup = await ApiService.createGroup({
        'name': name,
        'description': description,
        'color': colorHex,
        'active': true,
      });
      await fetchGroups();
      _selectedGroup = _groups.firstWhere((g) => g.id == newGroup.id, orElse: () => newGroup);
      await refreshGroupData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGroup(int id, String name, String? description, String colorHex, bool active) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.updateGroup(id, {
        'name': name,
        'description': description,
        'color': colorHex,
        'active': active,
      });
      await fetchGroups();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGroup(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.deleteGroup(id);
      await fetchGroups();
      _selectedGroup = _groups.isNotEmpty ? _groups.first : null;
      await refreshGroupData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Subject Management ---
  Future<bool> addSubject(String name, String colorHex, int targetMinutes, {int? groupId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.createSubject({
        'name': name,
        'color': colorHex,
        'active': true,
        'targetMinutes': targetMinutes,
        'groupId': groupId ?? _selectedGroup?.id,
      });
      await fetchSubjects();
      await fetchSuggestion();
      await fetchGroups();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(int id, String name, String colorHex, bool active, int targetMinutes, {int? groupId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.updateSubject(id, {
        'name': name,
        'color': colorHex,
        'active': active,
        'targetMinutes': targetMinutes,
        'groupId': groupId ?? _selectedGroup?.id,
      });
      await fetchSubjects();
      await fetchSuggestion();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleSubjectActiveInCycle(Subject subject) async {
    try {
      final updated = await ApiService.toggleActiveInCycle(subject.id);
      final index = _subjects.indexWhere((s) => s.id == subject.id);
      if (index >= 0) {
        _subjects[index] = updated;
      }
      await fetchSuggestion();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.deleteSubject(id);
      await fetchSubjects();
      await fetchSuggestion();
      await fetchDashboardStats();
      await fetchGroups();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> reorderCycle(List<int> subjectIds) async {
    _isLoading = true;
    notifyListeners();
    try {
      _subjects = await ApiService.reorderCycle(subjectIds, groupId: _selectedGroup?.id);
      await fetchSuggestion();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService.deleteSession(id);
      await Future.wait([
        fetchSubjects(),
        fetchSuggestion(),
        fetchDashboardStats(),
        fetchSessions(),
        fetchGroups(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
