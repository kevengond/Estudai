import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorNome = TextEditingController();
  final _controladorNomeUsuario = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorTelefone = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _controladorConfirmacaoSenha = TextEditingController();

  bool _ocultarSenha = true;
  bool _ocultarConfirmacaoSenha = true;

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorNomeUsuario.dispose();
    _controladorEmail.dispose();
    _controladorTelefone.dispose();
    _controladorSenha.dispose();
    _controladorConfirmacaoSenha.dispose();
    super.dispose();
  }

  Future<void> _enviarCadastro() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    final provedorAutenticacao =
        Provider.of<AuthProvider>(context, listen: false);
    final sucesso = await provedorAutenticacao.cadastrarUsuario(
      nome: _controladorNome.text.trim(),
      nomeUsuario: _controladorNomeUsuario.text.trim(),
      email: _controladorEmail.text.trim(),
      telefone: _controladorTelefone.text.trim(),
      senha: _controladorSenha.text,
    );

    if (sucesso && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ehModoEscuro = tema.brightness == Brightness.dark;
    final provedorAutenticacao = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabeçalho
                    Icon(
                      Icons.person_add_outlined,
                      size: 56,
                      color: tema.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Junte-se ao EstudAI',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Preencha seus dados para gerenciar seus estudos com segurança',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: ehModoEscuro ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mensagem de Erro
                    if (provedorAutenticacao.mensagemErro != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.3)),
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

                    // Campo Nome
                    TextFormField(
                      controller: _controladorNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe seu nome completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Usuário (nomeUsuario)
                    TextFormField(
                      controller: _controladorNomeUsuario,
                      decoration: const InputDecoration(
                        labelText: 'Nome de Usuário (login)',
                        prefixIcon: Icon(Icons.alternate_email),
                        hintText: 'Ex: keven.gond',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe um nome de usuário';
                        }
                        if (valor.trim().length < 3) {
                          return 'Mínimo de 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Email
                    TextFormField(
                      controller: _controladorEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        if (!valor.contains('@') || !valor.contains('.')) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Telefone
                    TextFormField(
                      controller: _controladorTelefone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone / WhatsApp',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '(11) 99999-9999',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Informe uma senha';
                        }
                        if (valor.length < 6) {
                          return 'A senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Confirmação de Senha
                    TextFormField(
                      controller: _controladorConfirmacaoSenha,
                      obscureText: _ocultarConfirmacaoSenha,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarConfirmacaoSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _ocultarConfirmacaoSenha =
                                  !_ocultarConfirmacaoSenha;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (valor) {
                        if (valor != _controladorSenha.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botão Cadastrar
                    ElevatedButton(
                      onPressed: provedorAutenticacao.estaCarregando
                          ? null
                          : _enviarCadastro,
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
                              'Concluir Cadastro',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Voltar para Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já possui uma conta?',
                          style: TextStyle(
                            color: ehModoEscuro
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fazer Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
