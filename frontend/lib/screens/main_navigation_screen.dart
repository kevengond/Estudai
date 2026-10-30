import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/screens/cycle_screen.dart';
import 'package:frontend/screens/dashboard_screen.dart';
import 'package:frontend/screens/history_screen.dart';
import 'package:frontend/screens/record_study_screen.dart';
import 'package:frontend/screens/subjects_screen.dart';
import 'package:frontend/widgets/group_selector_widget.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback aoAlternarTema;
  final bool ehModoEscuro;

  const MainNavigationScreen({
    super.key,
    VoidCallback? aoAlternarTema,
    VoidCallback? onToggleTheme,
    bool? ehModoEscuro,
    bool? isDarkMode,
  })  : aoAlternarTema = aoAlternarTema ?? onToggleTheme ?? _funcaoVazia,
        ehModoEscuro = ehModoEscuro ?? isDarkMode ?? false;

  static void _funcaoVazia() {}

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceAtual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyProvider>().carregarTodosDados();
    });
  }

  void _aoMudarAba(int novoIndice) {
    setState(() {
      _indiceAtual = novoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ehTelaLarga = MediaQuery.of(context).size.width > 800;

    final paginas = [
      DashboardScreen(aoNavegarParaAba: _aoMudarAba),
      RecordStudyScreen(aoSalvarSessao: () => _aoMudarAba(0)),
      CycleScreen(aoNavegarParaAba: _aoMudarAba),
      const SubjectsScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: tema.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'EstudAI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          const GroupSelectorWidget(),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(widget.ehModoEscuro
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: widget.aoAlternarTema,
            tooltip: widget.ehModoEscuro ? 'Tema Claro' : 'Tema Escuro',
          ),
          const SizedBox(width: 4),
          Consumer<AuthProvider>(
            builder: (contextoAuth, provedorAutenticacao, _) {
              final usuario = provedorAutenticacao.usuarioAtual;
              final iniciais = (usuario != null && usuario.nome.isNotEmpty)
                  ? usuario.nome
                      .trim()
                      .split(' ')
                      .map((parte) => parte[0])
                      .take(2)
                      .join()
                      .toUpperCase()
                  : 'U';

              return PopupMenuButton<String>(
                tooltip: 'Perfil do Usuário',
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: tema.colorScheme.primaryContainer,
                  child: Text(
                    iniciais,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tema.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                itemBuilder: (contextoMenu) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?.nome ?? 'Usuário',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '@${usuario?.nomeUsuario ?? ""}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (usuario?.email.isNotEmpty == true)
                          Text(
                            usuario!.email,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        if (usuario?.telefone != null &&
                            usuario!.telefone!.isNotEmpty)
                          Text(
                            usuario.telefone!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Sair', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (opcaoSelecionada) {
                  if (opcaoSelecionada == 'logout') {
                    contextoAuth.read<AuthProvider>().fazerLogout();
                  }
                },
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          if (ehTelaLarga)
            NavigationRail(
              selectedIndex: _indiceAtual,
              onDestinationSelected: _aoMudarAba,
              labelType: NavigationRailLabelType.all,
              leading: const SizedBox(height: 10),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Início'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: Text('Registrar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.sync_rounded),
                  selectedIcon: Icon(Icons.sync_rounded),
                  label: Text('Ciclo'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: Text('Matérias'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_rounded),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: Text('Histórico'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _indiceAtual,
              children: paginas,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ehTelaLarga
          ? null
          : NavigationBar(
              selectedIndex: _indiceAtual,
              onDestinationSelected: _aoMudarAba,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: 'Registrar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sync_rounded),
                  selectedIcon: Icon(Icons.sync_rounded),
                  label: 'Ciclo',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: 'Matérias',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: 'Histórico',
                ),
              ],
            ),
    );
  }
}
