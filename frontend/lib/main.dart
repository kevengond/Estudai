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
          create: (_) => AuthProvider()..verificarStatusAutenticacao(),
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
  ThemeMode _modoTema = ThemeMode.system;

  void _alternarTema() {
    setState(() {
      if (_modoTema == ThemeMode.dark) {
        _modoTema = ThemeMode.light;
      } else {
        _modoTema = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ehModoEscuro = _modoTema == ThemeMode.dark;

    return MaterialApp(
      title: 'EstudAI - Ciclo e Registro de Estudos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.temaClaro,
      darkTheme: AppTheme.temaEscuro,
      themeMode: _modoTema,
      home: Consumer<AuthProvider>(
        builder: (contexto, provedorAutenticacao, _) {
          if (provedorAutenticacao.estaCarregando) {
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

          if (provedorAutenticacao.estaAutenticado) {
            return MainNavigationScreen(
              aoAlternarTema: _alternarTema,
              ehModoEscuro: ehModoEscuro,
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
