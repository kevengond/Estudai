import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorLogin = TextEditingController();
  final _controladorSenha = TextEditingController();
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _controladorLogin.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _enviarLogin() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    final provedorAutenticacao =
        Provider.of<AuthProvider>(context, listen: false);
    await provedorAutenticacao.fazerLogin(
      _controladorLogin.text.trim(),
      _controladorSenha.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;
    final provedorAutenticacao = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: ehModoEscuro ? 2 : 8,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: ehModoEscuro ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _chaveFormulario,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logotipo / Cabeçalho
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  tema.colorScheme.primary,
                                  tema.colorScheme.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'EstudAI',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestão Inteligente de Ciclo de Estudos',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: ehModoEscuro
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Faixa de Erro
                        if (provedorAutenticacao.mensagemErro != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provedorAutenticacao.mensagemErro!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 16, color: Colors.red),
                                  onPressed: provedorAutenticacao.limparErro,
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Campo Usuário ou E-mail
                        TextFormField(
                          controller: _controladorLogin,
                          decoration: const InputDecoration(
                            labelText: 'Usuário ou E-mail',
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'admin ou seu@email.com',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe seu usuário ou e-mail';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Campo Senha
                        TextFormField(
                          controller: _controladorSenha,
                          obscureText: _ocultarSenha,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarSenha
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _ocultarSenha = !_ocultarSenha;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Informe sua senha';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _enviarLogin(),
                        ),
                        const SizedBox(height: 24),

                        // Botão Entrar
                        ElevatedButton(
                          onPressed: provedorAutenticacao.estaCarregando
                              ? null
                              : _enviarLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: tema.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: provedorAutenticacao.estaCarregando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Acessar Sistema',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Botão Criar Conta
                        OutlinedButton(
                          onPressed: () {
                            provedorAutenticacao.limparErro();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: tema.colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'Criar Nova Conta',
                            style: TextStyle(
                              color: tema.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Dica de login inicial
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ehModoEscuro
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Usuário padrão para testes:\nUsuário: admin | Senha: admin123',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: ehModoEscuro
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
