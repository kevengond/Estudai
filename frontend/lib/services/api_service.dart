import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/cycle_suggestion.dart';
import 'package:frontend/models/dashboard_stats.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    return 'http://10.0.2.2:8080/api';
  }

  // --- Study Groups (Concursos / Subgrupos) ---
  static Future<List<StudyGroup>> getGroups({bool activeOnly = false}) async {
    final uri = Uri.parse('$baseUrl/groups?activeOnly=$activeOnly');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((item) => StudyGroup.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar subgrupos: ${response.statusCode}');
    }
  }

  static Future<StudyGroup> createGroup(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/groups');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return StudyGroup.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao criar subgrupo: ${response.body}');
    }
  }

  static Future<StudyGroup> updateGroup(
      int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/groups/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return StudyGroup.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar subgrupo: ${response.body}');
    }
  }

  static Future<void> deleteGroup(int id) async {
    final uri = Uri.parse('$baseUrl/groups/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao remover subgrupo: ${response.statusCode}');
    }
  }

  // --- Subjects ---
  static Future<List<Subject>> getSubjects(
      {int? groupId, bool activeOnly = false}) async {
    final queryParams = <String, String>{'activeOnly': activeOnly.toString()};
    if (groupId != null) {
      queryParams['groupId'] = groupId.toString();
    }
    final uri = Uri.parse('$baseUrl/subjects').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((item) => Subject.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar disciplinas: ${response.statusCode}');
    }
  }

  static Future<Subject> createSubject(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/subjects');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Subject.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao criar disciplina: ${response.body}');
    }
  }

  static Future<Subject> updateSubject(
      int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/subjects/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Subject.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar disciplina: ${response.body}');
    }
  }

  static Future<Subject> toggleActiveInCycle(int id) async {
    final uri = Uri.parse('$baseUrl/subjects/$id/toggle-cycle');
    final response = await http.patch(uri);

    if (response.statusCode == 200) {
      return Subject.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao alternar disciplina no ciclo: ${response.statusCode}');
    }
  }

  static Future<void> deleteSubject(int id) async {
    final uri = Uri.parse('$baseUrl/subjects/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao remover disciplina: ${response.statusCode}');
    }
  }

  static Future<List<Subject>> reorderCycle(List<int> subjectIds,
      {int? groupId}) async {
    final uri = Uri.parse('$baseUrl/subjects/reorder');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'subjectIds': subjectIds,
        'groupId': groupId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((item) => Subject.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao reordenar ciclo: ${response.statusCode}');
    }
  }

  // --- Study Sessions ---
  static Future<List<StudySession>> getSessions({int? subjectId}) async {
    final uri = subjectId != null
        ? Uri.parse('$baseUrl/sessions?subjectId=$subjectId')
        : Uri.parse('$baseUrl/sessions');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((item) => StudySession.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar sessões: ${response.statusCode}');
    }
  }

  static Future<StudySession> createSession(
      Map<String, dynamic> sessionData) async {
    final uri = Uri.parse('$baseUrl/sessions');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(sessionData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return StudySession.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao salvar sessão de estudo: ${response.body}');
    }
  }

  static Future<void> deleteSession(int id) async {
    final uri = Uri.parse('$baseUrl/sessions/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao excluir sessão: ${response.statusCode}');
    }
  }

  // --- Cycle & Suggestions ---
  static Future<NextStudySuggestion> getNextStudySuggestion(
      {int? groupId}) async {
    final uri = groupId != null
        ? Uri.parse('$baseUrl/cycle/next-suggestion?groupId=$groupId')
        : Uri.parse('$baseUrl/cycle/next-suggestion');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return NextStudySuggestion.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
          'Falha ao carregar sugestão do ciclo: ${response.statusCode}');
    }
  }

  // --- Dashboard Stats ---
  static Future<DashboardStats> getDashboardStats({int? groupId}) async {
    final uri = groupId != null
        ? Uri.parse('$baseUrl/dashboard/stats?groupId=$groupId')
        : Uri.parse('$baseUrl/dashboard/stats');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao obter estatísticas: ${response.statusCode}');
    }
  }
}
