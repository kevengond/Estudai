import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _chaveToken = 'estudai_auth_token';
  static const String _chaveUsuario = 'estudai_user_data';

  bool _estaCarregando = true;
  bool _estaAutenticado = false;
  User? _usuarioAtual;
  String? _token;
  String? _mensagemErro;

  bool get estaCarregando => _estaCarregando;
  bool get isLoading => _estaCarregando;

  bool get estaAutenticado => _estaAutenticado;
  bool get isAuthenticated => _estaAutenticado;

  User? get usuarioAtual => _usuarioAtual;
  User? get currentUser => _usuarioAtual;

  String? get token => _token;

  String? get mensagemErro => _mensagemErro;
  String? get errorMessage => _mensagemErro;

  Future<void> verificarStatusAutenticacao() async {
    _estaCarregando = true;
    notifyListeners();

    try {
      final preferencias = await SharedPreferences.getInstance();
      final tokenSalvo = preferencias.getString(_chaveToken);
      final jsonUsuarioSalvo = preferencias.getString(_chaveUsuario);

      if (tokenSalvo != null && tokenSalvo.isNotEmpty) {
        ApiService.definirToken(tokenSalvo);
        _token = tokenSalvo;

        if (jsonUsuarioSalvo != null) {
          try {
            _usuarioAtual = User.fromJson(jsonDecode(jsonUsuarioSalvo));
          } catch (_) {}
        }

        // Valida token com o backend
        try {
          final usuario = await ApiService.obterUsuarioAtual();
          _usuarioAtual = usuario;
          _estaAutenticado = true;
          await preferencias.setString(_chaveUsuario, jsonEncode(usuario.toJson()));
        } catch (_) {
          // Se validação falhar, limpa sessão
          await fazerLogout();
          return;
        }
      } else {
        _estaAutenticado = false;
      }
    } catch (_) {
      _estaAutenticado = false;
    } finally {
      _estaCarregando = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() => verificarStatusAutenticacao();

  Future<bool> fazerLogin(String login, String senha) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resposta = await ApiService.fazerLogin(login, senha);
      _token = resposta.token;
      _usuarioAtual = resposta.usuario;
      _estaAutenticado = true;

      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(_chaveToken, resposta.token);
      await preferencias.setString(_chaveUsuario, jsonEncode(resposta.usuario.toJson()));

      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString().replaceAll('Exception: ', '');
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String login, String password) => fazerLogin(login, password);

  Future<bool> cadastrarUsuario({
    required String nome,
    required String nomeUsuario,
    required String email,
    String? telefone,
    required String senha,
  }) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final dados = {
        'name': nome,
        'username': nomeUsuario,
        'email': email,
        if (telefone != null && telefone.trim().isNotEmpty) 'phone': telefone.trim(),
        'password': senha,
      };

      final resposta = await ApiService.cadastrarUsuario(dados);
      _token = resposta.token;
      _usuarioAtual = resposta.usuario;
      _estaAutenticado = true;

      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(_chaveToken, resposta.token);
      await preferencias.setString(_chaveUsuario, jsonEncode(resposta.usuario.toJson()));

      _estaCarregando = false;
      notifyListeners();
      return true;
    } catch (excecao) {
      _mensagemErro = excecao.toString().replaceAll('Exception: ', '');
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    String? phone,
    required String password,
  }) =>
      cadastrarUsuario(
        nome: name,
        nomeUsuario: username,
        email: email,
        telefone: phone,
        senha: password,
      );

  Future<void> fazerLogout() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.remove(_chaveToken);
      await preferencias.remove(_chaveUsuario);
    } catch (_) {}

    ApiService.definirToken(null);
    _token = null;
    _usuarioAtual = null;
    _estaAutenticado = false;
    _mensagemErro = null;
    notifyListeners();
  }

  Future<void> logout() => fazerLogout();

  void limparErro() {
    _mensagemErro = null;
    notifyListeners();
  }

  void clearError() => limparErro();
}
