import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/cycle_suggestion.dart';
import 'package:frontend/models/dashboard_stats.dart';
import 'package:frontend/models/study_group.dart';
import 'package:frontend/models/study_session.dart';
import 'package:frontend/models/subject.dart';
import 'package:frontend/services/api_service.dart';

class StudyProvider extends ChangeNotifier {
  bool _estaCarregando = false;
  String? _mensagemErro;

  List<StudyGroup> _grupos = [];
  StudyGroup? _grupoSelecionado;

  List<Subject> _disciplinas = [];
  NextStudySuggestion? _sugestao;
  DashboardStats? _estatisticasPainel;
  List<StudySession> _sessoes = [];

  // Estado do Cronômetro
  Timer? _cronometro;
  int _segundosCronometro = 0;
  bool _cronometroEmExecucao = false;
  bool _cronometroPausado = false;

  // Estado do formulário de registro
  Subject? _disciplinaSelecionada;
  TipoEstudo _tipoEstudoSelecionado = TipoEstudo.questoes;
  String _topico = '';
  String _anotacoes = '';

  // Estado do modo questões
  int _totalQuestoes = 0;
  int _questoesCorretas = 0;

  // Estado do modo PDF
  String _tituloMaterial = '';
  int _paginaParada = 0;
  int _quantidadePaginasLidas = 0;

  // Getters em Português
  bool get estaCarregando => _estaCarregando;
  bool get isLoading => _estaCarregando;

  String? get mensagemErro => _mensagemErro;
  String? get errorMessage => _mensagemErro;

  List<StudyGroup> get grupos => _grupos;
  List<StudyGroup> get groups => _grupos;

  StudyGroup? get grupoSelecionado => _grupoSelecionado;
  StudyGroup? get selectedGroup => _grupoSelecionado;

  List<Subject> get disciplinas => _disciplinas;
  List<Subject> get subjects => _disciplinas;

  List<Subject> get disciplinasAtivas =>
      _disciplinas.where((disciplina) => disciplina.ativo).toList();
  List<Subject> get activeSubjects => disciplinasAtivas;

  NextStudySuggestion? get sugestao => _sugestao;
  NextStudySuggestion? get suggestion => _sugestao;

  DashboardStats? get estatisticasPainel => _estatisticasPainel;
  DashboardStats? get dashboardStats => _estatisticasPainel;

  List<StudySession> get sessoes => _sessoes;
  List<StudySession> get sessions => _sessoes;

  int get segundosCronometro => _segundosCronometro;
  int get timerSeconds => _segundosCronometro;

  bool get cronometroEmExecucao => _cronometroEmExecucao;
  bool get isTimerRunning => _cronometroEmExecucao;

  bool get cronometroPausado => _cronometroPausado;
  bool get isTimerPaused => _cronometroPausado;

  Subject? get disciplinaSelecionada => _disciplinaSelecionada;
  Subject? get selectedSubject => _disciplinaSelecionada;

  TipoEstudo get tipoEstudoSelecionado => _tipoEstudoSelecionado;
  TipoEstudo get selectedStudyType => _tipoEstudoSelecionado;

  String get topico => _topico;
  String get topic => _topico;

  String get anotacoes => _anotacoes;
  String get notes => _anotacoes;

  int get totalQuestoes => _totalQuestoes;
  int get totalQuestions => _totalQuestoes;

  int get questoesCorretas => _questoesCorretas;
  int get correctQuestions => _questoesCorretas;

  String get tituloMaterial => _tituloMaterial;
  String get materialTitle => _tituloMaterial;

  int get paginaParada => _paginaParada;
  int get pageStopped => _paginaParada;

  int get quantidadePaginasLidas => _quantidadePaginasLidas;
  int get pagesReadCount => _quantidadePaginasLidas;

  double get taxaAcertoAtual {
    if (_totalQuestoes <= 0) return 0.0;
    return (_questoesCorretas / _totalQuestoes) * 100.0;
  }
  double get currentAccuracyRate => taxaAcertoAtual;

  String get cronometroFormatado {
    final horas = _segundosCronometro ~/ 3600;
    final minutos = (_segundosCronometro % 3600) ~/ 60;
    final segundos = _segundosCronometro % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }
  String get formattedTimer => cronometroFormatado;

  // --- Inicialização e busca de dados ---
  Future<void> carregarTodosDados() async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await buscarGrupos();
      await Future.wait([
        buscarDisciplinas(),
        buscarSugestao(),
        buscarEstatisticasPainel(),
        buscarSessoes(),
      ]);
      if (_disciplinaSelecionada == null && _sugestao != null) {
        sincronizarComSugestaoAtual();
      }
    } catch (excecao) {
      _mensagemErro = excecao.toString();
    } finally {
      _estaCarregando = false;
      notifyListeners();
    }
  }

  Future<void> loadAllData() => carregarTodosDados();

  Future<void> buscarGrupos() async {
    try {
      _grupos = await ApiService.buscarGrupos();
      if (_grupos.isNotEmpty && _grupoSelecionado == null) {
        _grupoSelecionado = _grupos.first;
      }
      notifyListeners();
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      notifyListeners();
    }
  }

  Future<void> fetchGroups() => buscarGrupos();

  void selecionarGrupo(StudyGroup? grupo) {
    if (_grupoSelecionado?.id == grupo?.id) return;
    _grupoSelecionado = grupo;
    _disciplinaSelecionada = null;
    notifyListeners();
    atualizarDadosGrupo();
  }

  void selectGroup(StudyGroup? group) => selecionarGrupo(group);

  Future<void> atualizarDadosGrupo() async {
    _estaCarregando = true;
    notifyListeners();
    try {
      await Future.wait([
        buscarDisciplinas(),
        buscarSugestao(),
        buscarEstatisticasPainel(),
        buscarSessoes(),
      ]);
      if (!_cronometroEmExecucao && _sugestao != null) {
        sincronizarComSugestaoAtual();
      }
    } catch (excecao) {
      _mensagemErro = excecao.toString();
    } finally {
      _estaCarregando = false;
      notifyListeners();
    }
  }

  Future<void> refreshGroupData() => atualizarDadosGrupo();

  Future<void> buscarDisciplinas() async {
    try {
      _disciplinas = await ApiService.buscarDisciplinas(idGrupo: _grupoSelecionado?.id);
      if (_disciplinaSelecionada == null && _disciplinas.isNotEmpty) {
        _disciplinaSelecionada = _disciplinas.firstWhere(
          (disciplina) => disciplina.ativo,
          orElse: () => _disciplinas.first,
        );
      }
      notifyListeners();
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSubjects() => buscarDisciplinas();

  Future<void> buscarSugestao() async {
    try {
      _sugestao = await ApiService.buscarProximaSugestaoEstudo(idGrupo: _grupoSelecionado?.id);
      notifyListeners();
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSuggestion() => buscarSugestao();

  Future<void> buscarEstatisticasPainel() async {
    try {
      _estatisticasPainel = await ApiService.buscarEstatisticasPainel(idGrupo: _grupoSelecionado?.id);
      notifyListeners();
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDashboardStats() => buscarEstatisticasPainel();

  Future<void> buscarSessoes({int? idDisciplina}) async {
    try {
      _sessoes = await ApiService.buscarSessoes(idDisciplina: idDisciplina);
      if (_grupoSelecionado != null && idDisciplina == null) {
        final conjuntoIdsDisciplinas = _disciplinas.map((disciplina) => disciplina.id).toSet();
        _sessoes = _sessoes
            .where((sessao) => conjuntoIdsDisciplinas.contains(sessao.idDisciplina))
            .toList();
      }
      notifyListeners();
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSessions({int? subjectId}) => buscarSessoes(idDisciplina: subjectId);

  // --- Controles do Cronômetro ---
  void iniciarCronometro() {
    if (_cronometroEmExecucao) return;
    _cronometroEmExecucao = true;
    _cronometroPausado = false;
    _cronometro = Timer.periodic(const Duration(seconds: 1), (_) {
      _segundosCronometro++;
      notifyListeners();
    });
    notifyListeners();
  }

  void startTimer() => iniciarCronometro();

  void pausarCronometro() {
    if (!_cronometroEmExecucao) return;
    _cronometro?.cancel();
    _cronometroEmExecucao = false;
    _cronometroPausado = true;
    notifyListeners();
  }

  void pauseTimer() => pausarCronometro();

  void retomarCronometro() {
    if (_cronometroEmExecucao) return;
    iniciarCronometro();
  }

  void resumeTimer() => retomarCronometro();

  void redefinirCronometro() {
    _cronometro?.cancel();
    _segundosCronometro = 0;
    _cronometroEmExecucao = false;
    _cronometroPausado = false;
    notifyListeners();
  }

  void resetTimer() => redefinirCronometro();

  void definirDuracaoManual(int segundos) {
    _segundosCronometro = segundos;
    notifyListeners();
  }

  void setManualDuration(int seconds) => definirDuracaoManual(seconds);

  // --- Modificadores do Formulário ---
  void definirDisciplinaSelecionada(Subject? disciplina) {
    _disciplinaSelecionada = disciplina;
    notifyListeners();
  }

  void setSelectedSubject(Subject? subject) => definirDisciplinaSelecionada(subject);

  void definirTipoEstudoSelecionado(TipoEstudo tipo) {
    _tipoEstudoSelecionado = tipo;
    notifyListeners();
  }

  void setSelectedStudyType(TipoEstudo type) => definirTipoEstudoSelecionado(type);

  void definirTopico(String valor) {
    _topico = valor;
    notifyListeners();
  }

  void setTopic(String val) => definirTopico(val);

  void definirAnotacoes(String valor) {
    _anotacoes = valor;
    notifyListeners();
  }

  void setNotes(String val) => definirAnotacoes(val);

  void definirTotalQuestoes(int valor) {
    _totalQuestoes = valor;
    if (_questoesCorretas > _totalQuestoes) {
      _questoesCorretas = _totalQuestoes;
    }
    notifyListeners();
  }

  void setTotalQuestions(int val) => definirTotalQuestoes(val);

  void definirQuestoesCorretas(int valor) {
    _questoesCorretas = valor;
    notifyListeners();
  }

  void setCorrectQuestions(int val) => definirQuestoesCorretas(val);

  void definirTituloMaterial(String valor) {
    _tituloMaterial = valor;
    notifyListeners();
  }

  void setMaterialTitle(String val) => definirTituloMaterial(val);

  void definirPaginaParada(int valor) {
    _paginaParada = valor;
    notifyListeners();
  }

  void setPageStopped(int val) => definirPaginaParada(val);

  void definirQuantidadePaginasLidas(int valor) {
    _quantidadePaginasLidas = valor;
    notifyListeners();
  }

  void setPagesReadCount(int val) => definirQuantidadePaginasLidas(val);

  // --- Pré-preenchimento a partir de sugestão ---
  void prepararAPartirDeSugestao(
    NextStudySuggestion sugestaoEstudo, {
    bool redefinirCronometroAoPreparar = true,
  }) {
    if (sugestaoEstudo.disciplinaSugerida != null) {
      final correspondencia = _disciplinas.firstWhere(
        (disciplina) => disciplina.id == sugestaoEstudo.disciplinaSugerida!.id,
        orElse: () => sugestaoEstudo.disciplinaSugerida!,
      );
      _disciplinaSelecionada = correspondencia;
    }

    if (sugestaoEstudo.tipoEstudoSugerido != null) {
      _tipoEstudoSelecionado = sugestaoEstudo.tipoEstudoSugerido!;
    }

    if (sugestaoEstudo.tipoEstudoSugerido == TipoEstudo.pdf) {
      _tituloMaterial = sugestaoEstudo.materialOuTopicoSugerido ?? '';
      _paginaParada = sugestaoEstudo.paginaSugerida ?? 0;
      _quantidadePaginasLidas = 0;
      _topico = '';
    } else {
      _topico = sugestaoEstudo.materialOuTopicoSugerido ?? '';
      if (_topico == 'Introdução / Bloco Inicial') _topico = '';
      _totalQuestoes = sugestaoEstudo.loteQuestoesSugerido ?? 20;
      _questoesCorretas = 0;
      _tituloMaterial = '';
      _paginaParada = 0;
      _quantidadePaginasLidas = 0;
    }

    if (redefinirCronometroAoPreparar) {
      redefinirCronometro();
    }
    notifyListeners();
  }

  void prepareFromSuggestion(NextStudySuggestion sugg, {bool resetTimerOnPrepare = true}) =>
      prepararAPartirDeSugestao(sugg, redefinirCronometroAoPreparar: resetTimerOnPrepare);

  void sincronizarComSugestaoAtual({bool forcar = false}) {
    if (_sugestao != null && (!_cronometroEmExecucao || forcar)) {
      prepararAPartirDeSugestao(_sugestao!, redefinirCronometroAoPreparar: false);
    }
  }

  void syncWithCurrentSuggestion({bool force = false}) =>
      sincronizarComSugestaoAtual(forcar: force);

  void prepararAPartirDeDisciplina(Subject disciplina) {
    _disciplinaSelecionada = disciplina;
    final ultimaSessao = _sessoes
        .where((sessao) => sessao.idDisciplina == disciplina.id)
        .firstOrNull;

    if (ultimaSessao != null) {
      _tipoEstudoSelecionado = ultimaSessao.tipoEstudo;
      if (ultimaSessao.tipoEstudo == TipoEstudo.pdf) {
        _tituloMaterial =
            ultimaSessao.tituloMaterial ?? ultimaSessao.topico ?? '';
        _paginaParada = ultimaSessao.paginaParada ?? 0;
        _quantidadePaginasLidas = 0;
        _topico = '';
      } else {
        _topico = ultimaSessao.topico ?? '';
        _totalQuestoes = ultimaSessao.totalQuestoes ?? 20;
        _questoesCorretas = 0;
        _tituloMaterial = '';
        _paginaParada = 0;
        _quantidadePaginasLidas = 0;
      }
    } else {
      _tipoEstudoSelecionado = TipoEstudo.questoes;
      _topico = '';
      _totalQuestoes = 20;
      _questoesCorretas = 0;
      _tituloMaterial = '';
      _paginaParada = 0;
      _quantidadePaginasLidas = 0;
    }
    redefinirCronometro();
    notifyListeners();
  }

  void prepareFromSubject(Subject subject) =>
      prepararAPartirDeDisciplina(subject);

  // --- Salvar Sessão ---
  Future<bool> salvarSessaoAtual() async {
    if (_disciplinaSelecionada == null) {
      _mensagemErro = 'Selecione uma disciplina para registrar o estudo.';
      notifyListeners();
      return false;
    }

    if (_segundosCronometro <= 0) {
      _mensagemErro = 'O tempo de estudo deve ser maior que zero.';
      notifyListeners();
      return false;
    }

    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final dadosSessao = {
        'subjectId': _disciplinaSelecionada!.id,
        'studyType': tipoEstudoParaTexto(_tipoEstudoSelecionado),
        'durationSeconds': _segundosCronometro,
        'topic': _topico.isNotEmpty ? _topico : null,
        'notes': _anotacoes.isNotEmpty ? _anotacoes : null,
        'sessionDate': DateTime.now().toIso8601String(),
        'totalQuestions': _tipoEstudoSelecionado == TipoEstudo.questoes
            ? _totalQuestoes
            : null,
        'correctQuestions': _tipoEstudoSelecionado == TipoEstudo.questoes
            ? _questoesCorretas
            : null,
        'materialTitle': _tipoEstudoSelecionado == TipoEstudo.pdf
            ? _tituloMaterial
            : null,
        'pageStopped': _tipoEstudoSelecionado == TipoEstudo.pdf
            ? _paginaParada
            : null,
        'pagesReadCount': _tipoEstudoSelecionado == TipoEstudo.pdf
            ? _quantidadePaginasLidas
            : null,
      };

      await ApiService.criarSessao(dadosSessao);
      redefinirCronometro();
      _topico = '';
      _anotacoes = '';
      _totalQuestoes = 0;
      _questoesCorretas = 0;
      _tituloMaterial = '';
      _paginaParada = 0;
      _quantidadePaginasLidas = 0;

      await Future.wait([
        buscarGrupos(),
        buscarDisciplinas(),
        buscarSugestao(),
        buscarEstatisticasPainel(),
        buscarSessoes(),
      ]);

      final proximaSugestao = _sugestao;
      final proximaDisciplina = proximaSugestao?.disciplinaSugerida;
      if (proximaSugestao != null && proximaDisciplina != null) {
        try {
          final correspondente = _disciplinas.firstWhere(
            (disciplina) => disciplina.id == proximaDisciplina.id,
            orElse: () => proximaDisciplina,
          );
          _disciplinaSelecionada = correspondente;
        } catch (_) {
          _disciplinaSelecionada = proximaDisciplina;
        }

        final proximoTipo = proximaSugestao.tipoEstudoSugerido;
        if (proximoTipo != null) {
          _tipoEstudoSelecionado = proximoTipo;
        }
        if (proximoTipo == TipoEstudo.pdf) {
          _tituloMaterial =
              proximaSugestao.materialOuTopicoSugerido ?? '';
          _paginaParada = proximaSugestao.paginaSugerida ?? 0;
          _quantidadePaginasLidas = 0;
          _topico = '';
        } else if (proximoTipo == TipoEstudo.questoes) {
          _topico = proximaSugestao.materialOuTopicoSugerido ?? '';
          if (_topico == 'Introdução / Bloco Inicial') _topico = '';
          _totalQuestoes = proximaSugestao.loteQuestoesSugerido ?? 20;
          _questoesCorretas = 0;
          _tituloMaterial = '';
          _paginaParada = 0;
          _quantidadePaginasLidas = 0;
        }
        _anotacoes = '';
      }

      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveCurrentSession() => salvarSessaoAtual();

  // --- Gestão de Subgrupos / Concursos ---
  Future<bool> adicionarGrupo(
      String nome, String? descricao, String corHex) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final novoGrupo = await ApiService.criarGrupo({
        'name': nome,
        'description': descricao,
        'color': corHex,
        'active': true,
      });
      await buscarGrupos();
      _grupoSelecionado = _grupos.firstWhere(
        (grupo) => grupo.id == novoGrupo.id,
        orElse: () => novoGrupo,
      );
      await atualizarDadosGrupo();
      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addGroup(String name, String? description, String colorHex) =>
      adicionarGrupo(name, description, colorHex);

  Future<bool> atualizarGrupo(
    int id,
    String nome,
    String? descricao,
    String corHex,
    bool ativo,
  ) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await ApiService.atualizarGrupo(id, {
        'name': nome,
        'description': descricao,
        'color': corHex,
        'active': ativo,
      });
      await buscarGrupos();
      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGroup(int id, String name, String? description,
          String colorHex, bool active) =>
      atualizarGrupo(id, name, description, colorHex, active);

  Future<bool> excluirGrupo(int id) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await ApiService.excluirGrupo(id);
      await buscarGrupos();
      _grupoSelecionado = _grupos.isNotEmpty ? _grupos.first : null;
      await atualizarDadosGrupo();
      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGroup(int id) => excluirGrupo(id);

  // --- Gestão de Disciplinas ---
  Future<bool> adicionarDisciplina(
    String nome,
    String corHex,
    int metaMinutos, {
    int? idGrupo,
  }) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await ApiService.criarDisciplina({
        'name': nome,
        'color': corHex,
        'active': true,
        'targetMinutes': metaMinutos,
        'groupId': idGrupo ?? _grupoSelecionado?.id,
      });
      await buscarDisciplinas();
      await buscarSugestao();
      await buscarGrupos();
      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSubject(String name, String colorHex, int targetMinutes,
          {int? groupId}) =>
      adicionarDisciplina(name, colorHex, targetMinutes, idGrupo: groupId);

  Future<bool> atualizarDisciplina(
    int id,
    String nome,
    String corHex,
    bool ativo,
    int metaMinutos, {
    int? idGrupo,
  }) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await ApiService.atualizarDisciplina(id, {
        'name': nome,
        'color': corHex,
        'active': ativo,
        'targetMinutes': metaMinutos,
        'groupId': idGrupo ?? _grupoSelecionado?.id,
      });
      await buscarDisciplinas();
      await buscarSugestao();
      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(int id, String name, String colorHex, bool active,
          int targetMinutes, {int? groupId}) =>
      atualizarDisciplina(id, name, colorHex, active, targetMinutes,
          idGrupo: groupId);

  Future<bool> alternarDisciplinaAtivaNoCiclo(Subject disciplina) async {
    try {
      final disciplinaAtualizada =
          await ApiService.alternarAtivaNoCiclo(disciplina.id);
      final indice =
          _disciplinas.indexWhere((item) => item.id == disciplina.id);
      if (indice >= 0) {
        _disciplinas[indice] = disciplinaAtualizada;
      }
      await buscarDisciplinas();
      await buscarSugestao();
      sincronizarComSugestaoAtual();
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleSubjectActiveInCycle(Subject subject) =>
      alternarDisciplinaAtivaNoCiclo(subject);

  Future<bool> excluirDisciplina(int id) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await ApiService.excluirDisciplina(id);
      await buscarDisciplinas();
      await buscarSugestao();
      await buscarEstatisticasPainel();
      await buscarGrupos();
      sincronizarComSugestaoAtual();
      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString();
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(int id) => excluirDisciplina(id);

  Future<void> reordenarCiclo(List<int> idsDisciplinas) async {
    _estaCarregando = true;
    notifyListeners();
    try {
      _disciplinas = await ApiService.reordenarCiclo(idsDisciplinas,
          idGrupo: _grupoSelecionado?.id);
      await buscarSugestao();
      sincronizarComSugestaoAtual();
    } catch (excecao) {
      _mensagemErro = excecao.toString();
    } finally {
      _estaCarregando = false;
      notifyListeners();
    }
  }

  Future<void> reorderCycle(List<int> subjectIds) =>
      reordenarCiclo(subjectIds);

  Future<void> excluirSessao(int id) async {
    _estaCarregando = true;
    notifyListeners();
    try {
      await ApiService.excluirSessao(id);
      await Future.wait([
        buscarDisciplinas(),
        buscarSugestao(),
        buscarEstatisticasPainel(),
        buscarSessoes(),
        buscarGrupos(),
      ]);
    } catch (excecao) {
      _mensagemErro = excecao.toString();
    } finally {
      _estaCarregando = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(int id) => excluirSessao(id);

  @override
  void dispose() {
    _cronometro?.cancel();
    super.dispose();
  }
}
