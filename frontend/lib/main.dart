import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/study_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_navigation_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => StudyProvider(),
        ),
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(
                      color: Color(0xFF4F46E5),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            );
          }

          if (auth.isAuthenticated) {
            return MainNavigationScreen(
              onToggleTheme: _toggleTheme,
              isDarkMode: isDark,
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
