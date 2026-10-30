import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color corPrimaria = Color(0xFF6366F1); // Índigo
  static const Color corSecundaria = Color(0xFF06B6D4); // Ciano
  static const Color destaqueSucesso = Color(0xFF10B981); // Esmeralda
  static const Color destaqueAviso = Color(0xFFF59E0B); // Âmbar
  static const Color destaquePerigo = Color(0xFFEF4444); // Vermelho

  static const Color fundoEscuro = Color(0xFF0F172A); // Slate 900
  static const Color superficieEscura = Color(0xFF1E293B); // Slate 800
  static const Color cartaoEscuro = Color(0xFF1E293B);

  static const Color fundoClaro = Color(0xFFF8FAFC); // Slate 50
  static const Color superficieClara = Colors.white;
  static const Color cartaoClaro = Colors.white;

  // Aliases para compatibilidade
  static const Color primaryColor = corPrimaria;
  static const Color secondaryColor = corSecundaria;
  static const Color accentSuccess = destaqueSucesso;
  static const Color accentWarning = destaqueAviso;
  static const Color accentDanger = destaquePerigo;
  static const Color darkBackground = fundoEscuro;
  static const Color darkSurface = superficieEscura;
  static const Color darkCard = cartaoEscuro;
  static const Color lightBackground = fundoClaro;
  static const Color lightSurface = superficieClara;
  static const Color lightCard = cartaoClaro;

  static ThemeData get temaClaro {
    final temaTexto = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: corPrimaria,
        secondary: corSecundaria,
        surface: superficieClara,
        error: destaquePerigo,
      ),
      scaffoldBackgroundColor: fundoClaro,
      cardTheme: CardThemeData(
        color: cartaoClaro,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: corPrimaria, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textTheme: temaTexto,
    );
  }

  static ThemeData get lightTheme => temaClaro;

  static ThemeData get temaEscuro {
    final temaTexto = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: corPrimaria,
        secondary: corSecundaria,
        surface: superficieEscura,
        error: destaquePerigo,
      ),
      scaffoldBackgroundColor: fundoEscuro,
      cardTheme: CardThemeData(
        color: cartaoEscuro,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: corPrimaria, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textTheme: temaTexto,
    );
  }

  static ThemeData get darkTheme => temaEscuro;
}
