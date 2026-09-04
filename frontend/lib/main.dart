import 'package:flutter/material.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/screens/main_navigation_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyProvider()),
      ],
      child: const EstudaiApp(),
    ),
  );
}

class EstudaiApp extends StatefulWidget {
  const EstudaiApp({super.key});

  @override
  State<EstudaiApp> createState() => _EstudaiAppState();
}

class _EstudaiAppState extends State<EstudaiApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'EstudAI - Ciclo e Registro de Estudos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: isDark,
      ),
    );
  }
}
