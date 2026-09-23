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
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainNavigationScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyProvider>().loadAllData();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    final pages = [
      DashboardScreen(onNavigateToTab: _onTabChanged),
      RecordStudyScreen(onSessionSaved: () => _onTabChanged(0)),
      CycleScreen(onNavigateToTab: _onTabChanged),
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
                color: theme.colorScheme.primary,
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
            icon: Icon(widget.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Tema Claro' : 'Tema Escuro',
          ),
          const SizedBox(width: 4),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final user = auth.currentUser;
              final initials = (user != null && user.name.isNotEmpty)
                  ? user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                  : 'U';

              return PopupMenuButton<String>(
                tooltip: 'Perfil do Usuário',
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuário',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '@${user?.username ?? ""}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (user?.email.isNotEmpty == true)
                          Text(
                            user!.email,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        if (user?.phone != null && user!.phone!.isNotEmpty)
                          Text(
                            user.phone!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthProvider>().logout();
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
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabChanged,
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
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabChanged,
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
