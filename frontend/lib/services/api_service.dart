import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/cycle_suggestion.dart';
import 'package:frontend/models/dashboard_stats.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String? _token;

  static void definirToken(String? novoToken) {
    _token = novoToken;
  }

  static void setToken(String? token) => definirToken(token);

  static String? get token => _token;

  static String get urlBase {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    return 'http://10.0.2.2:8080/api';
  }

  static String get baseUrl => urlBase;

  static Map<String, String> get _cabecalhos {
    final cabecalhos = {'Content-Type': 'application/json; charset=UTF-8'};
    if (_token != null && _token!.isNotEmpty) {
      cabecalhos['Authorization'] = 'Bearer $_token';
    }
    return cabecalhos;
  }

  static Map<String, String> get _headers => _cabecalhos;

  // --- Autenticação ---
  static Future<AuthResponse> fazerLogin(String login, String senha) async {
    final uri = Uri.parse('$urlBase/auth/login');
    final resposta = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'login': login,
        'password': senha,
      }),
    );

    if (resposta.statusCode == 200) {
      final dadosResposta = jsonDecode(utf8.decode(resposta.bodyBytes));
      final respostaAutenticacao = AuthResponse.fromJson(dadosResposta);
      definirToken(respostaAutenticacao.token);
      return respostaAutenticacao;
    } else {
      String mensagemErro = 'Falha no login';
      try {
        final jsonErro = jsonDecode(utf8.decode(resposta.bodyBytes));
        if (jsonErro['message'] != null) {
          mensagemErro = jsonErro['message'];
        }
      } catch (_) {}
      throw Exception(mensagemErro);
    }
  }

  static Future<AuthResponse> login(String login, String password) =>
      fazerLogin(login, password);

  static Future<AuthResponse> cadastrarUsuario(Map<String, dynamic> dadosCadastro) async {
    final uri = Uri.parse('$urlBase/auth/register');
    final resposta = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(dadosCadastro),
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      final dadosResposta = jsonDecode(utf8.decode(resposta.bodyBytes));
      final respostaAutenticacao = AuthResponse.fromJson(dadosResposta);
      definirToken(respostaAutenticacao.token);
      return respostaAutenticacao;
    } else {
      String mensagemErro = 'Falha no cadastro';
      try {
        final jsonErro = jsonDecode(utf8.decode(resposta.bodyBytes));
        if (jsonErro['message'] != null) {
          mensagemErro = jsonErro['message'];
        }
      } catch (_) {}
      throw Exception(mensagemErro);
    }
  }

  static Future<AuthResponse> register(Map<String, dynamic> data) =>
      cadastrarUsuario(data);

  static Future<User> obterUsuarioAtual() async {
    final uri = Uri.parse('$urlBase/auth/me');
    final resposta = await http.get(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      return User.fromJson(dados);
    } else {
      throw Exception('Sessão expirada ou não autenticado');
    }
  }

  static Future<User> getMe() => obterUsuarioAtual();

  // --- Subgrupos / Concursos ---
  static Future<List<StudyGroup>> buscarGrupos({bool apenasAtivos = false}) async {
    final uri = Uri.parse('$urlBase/groups?activeOnly=$apenasAtivos');
    final resposta = await http.get(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      final List<dynamic> listaJson = jsonDecode(utf8.decode(resposta.bodyBytes));
      return listaJson.map((item) => StudyGroup.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar subgrupos: ${resposta.statusCode}');
    }
  }

  static Future<List<StudyGroup>> getGroups({bool activeOnly = false}) =>
      buscarGrupos(apenasAtivos: activeOnly);

  static Future<StudyGroup> criarGrupo(Map<String, dynamic> dados) async {
    final uri = Uri.parse('$urlBase/groups');
    final resposta = await http.post(
      uri,
      headers: _cabecalhos,
      body: jsonEncode(dados),
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      return StudyGroup.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception('Falha ao criar subgrupo: ${resposta.body}');
    }
  }

  static Future<StudyGroup> createGroup(Map<String, dynamic> data) =>
      criarGrupo(data);

  static Future<StudyGroup> atualizarGrupo(
      int id, Map<String, dynamic> dados) async {
    final uri = Uri.parse('$urlBase/groups/$id');
    final resposta = await http.put(
      uri,
      headers: _cabecalhos,
      body: jsonEncode(dados),
    );

    if (resposta.statusCode == 200) {
      return StudyGroup.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar subgrupo: ${resposta.body}');
    }
  }

  static Future<StudyGroup> updateGroup(int id, Map<String, dynamic> data) =>
      atualizarGrupo(id, data);

  static Future<void> excluirGrupo(int id) async {
    final uri = Uri.parse('$urlBase/groups/$id');
    final resposta = await http.delete(uri, headers: _cabecalhos);

    if (resposta.statusCode != 204 && resposta.statusCode != 200) {
      throw Exception('Falha ao remover subgrupo: ${resposta.statusCode}');
    }
  }

  static Future<void> deleteGroup(int id) => excluirGrupo(id);

  // --- Disciplinas ---
  static Future<List<Subject>> buscarDisciplinas(
      {int? idGrupo, bool apenasAtivas = false}) async {
    final parametrosConsulta = <String, String>{
      'activeOnly': apenasAtivas.toString(),
    };
    if (idGrupo != null) {
      parametrosConsulta['groupId'] = idGrupo.toString();
    }
    final uri =
        Uri.parse('$urlBase/subjects').replace(queryParameters: parametrosConsulta);
    final resposta = await http.get(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      final List<dynamic> listaJson = jsonDecode(utf8.decode(resposta.bodyBytes));
      return listaJson.map((item) => Subject.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar disciplinas: ${resposta.statusCode}');
    }
  }

  static Future<List<Subject>> getSubjects(
          {int? groupId, bool activeOnly = false}) =>
      buscarDisciplinas(idGrupo: groupId, apenasAtivas: activeOnly);

  static Future<Subject> criarDisciplina(Map<String, dynamic> dados) async {
    final uri = Uri.parse('$urlBase/subjects');
    final resposta = await http.post(
      uri,
      headers: _cabecalhos,
      body: jsonEncode(dados),
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      return Subject.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception('Falha ao criar disciplina: ${resposta.body}');
    }
  }

  static Future<Subject> createSubject(Map<String, dynamic> data) =>
      criarDisciplina(data);

  static Future<Subject> atualizarDisciplina(
      int id, Map<String, dynamic> dados) async {
    final uri = Uri.parse('$urlBase/subjects/$id');
    final resposta = await http.put(
      uri,
      headers: _cabecalhos,
      body: jsonEncode(dados),
    );

    if (resposta.statusCode == 200) {
      return Subject.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar disciplina: ${resposta.body}');
    }
  }

  static Future<Subject> updateSubject(int id, Map<String, dynamic> data) =>
      atualizarDisciplina(id, data);

  static Future<Subject> alternarAtivaNoCiclo(int id) async {
    final uri = Uri.parse('$urlBase/subjects/$id/toggle-cycle');
    final resposta = await http.patch(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      return Subject.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception(
          'Falha ao alternar disciplina no ciclo: ${resposta.statusCode}');
    }
  }

  static Future<Subject> toggleActiveInCycle(int id) =>
      alternarAtivaNoCiclo(id);

  static Future<void> excluirDisciplina(int id) async {
    final uri = Uri.parse('$urlBase/subjects/$id');
    final resposta = await http.delete(uri, headers: _cabecalhos);

    if (resposta.statusCode != 204 && resposta.statusCode != 200) {
      throw Exception('Falha ao remover disciplina: ${resposta.statusCode}');
    }
  }

  static Future<void> deleteSubject(int id) => excluirDisciplina(id);

  static Future<List<Subject>> reordenarCiclo(List<int> idsDisciplinas,
      {int? idGrupo}) async {
    final uri = Uri.parse('$urlBase/subjects/reorder');
    final resposta = await http.post(
      uri,
      headers: _cabecalhos,
      body: jsonEncode({
        'subjectIds': idsDisciplinas,
        'groupId': idGrupo,
      }),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> listaJson = jsonDecode(utf8.decode(resposta.bodyBytes));
      return listaJson.map((item) => Subject.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao reordenar ciclo: ${resposta.statusCode}');
    }
  }

  static Future<List<Subject>> reorderCycle(List<int> subjectIds,
          {int? groupId}) =>
      reordenarCiclo(subjectIds, idGrupo: groupId);

  // --- Sessões de Estudo ---
  static Future<List<StudySession>> buscarSessoes({int? idDisciplina}) async {
    final uri = idDisciplina != null
        ? Uri.parse('$urlBase/sessions?subjectId=$idDisciplina')
        : Uri.parse('$urlBase/sessions');
    final resposta = await http.get(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      final List<dynamic> listaJson = jsonDecode(utf8.decode(resposta.bodyBytes));
      return listaJson.map((item) => StudySession.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar sessões: ${resposta.statusCode}');
    }
  }

  static Future<List<StudySession>> getSessions({int? subjectId}) =>
      buscarSessoes(idDisciplina: subjectId);

  static Future<StudySession> criarSessao(
      Map<String, dynamic> dadosSessao) async {
    final uri = Uri.parse('$urlBase/sessions');
    final resposta = await http.post(
      uri,
      headers: _cabecalhos,
      body: jsonEncode(dadosSessao),
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      return StudySession.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception('Falha ao salvar sessão de estudo: ${resposta.body}');
    }
  }

  static Future<StudySession> createSession(Map<String, dynamic> sessionData) =>
      criarSessao(sessionData);

  static Future<void> excluirSessao(int id) async {
    final uri = Uri.parse('$urlBase/sessions/$id');
    final resposta = await http.delete(uri, headers: _cabecalhos);

    if (resposta.statusCode != 204 && resposta.statusCode != 200) {
      throw Exception('Falha ao excluir sessão: ${resposta.statusCode}');
    }
  }

  static Future<void> deleteSession(int id) => excluirSessao(id);

  // --- Ciclo e Sugestões ---
  static Future<NextStudySuggestion> buscarProximaSugestaoEstudo(
      {int? idGrupo}) async {
    final uri = idGrupo != null
        ? Uri.parse('$urlBase/cycle/next-suggestion?groupId=$idGrupo')
        : Uri.parse('$urlBase/cycle/next-suggestion');
    final resposta = await http.get(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      return NextStudySuggestion.fromJson(
          jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception(
          'Falha ao carregar sugestão do ciclo: ${resposta.statusCode}');
    }
  }

  static Future<NextStudySuggestion> getNextStudySuggestion({int? groupId}) =>
      buscarProximaSugestaoEstudo(idGrupo: groupId);

  // --- Estatísticas do Painel ---
  static Future<DashboardStats> buscarEstatisticasPainel({int? idGrupo}) async {
    final uri = idGrupo != null
        ? Uri.parse('$urlBase/dashboard/stats?groupId=$idGrupo')
        : Uri.parse('$urlBase/dashboard/stats');
    final resposta = await http.get(uri, headers: _cabecalhos);

    if (resposta.statusCode == 200) {
      return DashboardStats.fromJson(
          jsonDecode(utf8.decode(resposta.bodyBytes)));
    } else {
      throw Exception('Falha ao obter estatísticas: ${resposta.statusCode}');
    }
  }

  static Future<DashboardStats> getDashboardStats({int? groupId}) =>
      buscarEstatisticasPainel(idGrupo: groupId);
}
