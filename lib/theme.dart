import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF08080A);
  static const card = Color(0xFF111114);
  static const cardLight = Color(0xFF18181D);
  static const border = Color(0xFF23232A);
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFF9D6BFF);
  static const primaryDark = Color(0xFF5B21B6);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFF43F5E);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const textMuted = Color(0xFF71717A);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const balanceGradient = LinearGradient(
    colors: [Color(0xFF2E1572), Color(0xFF1A0F3D), Color(0xFF111114)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

TextStyle numStyle({
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
}) => GoogleFonts.inter(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  fontFeatures: const [FontFeature.tabularFigures()],
);

class AppPalette {
  final bool isDark;
  final Color bg;
  final Color bgSecondary;
  final Color card;
  final Color cardAlt;
  final Color field;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color navBg;
  final LinearGradient heroGradient;

  const AppPalette({
    required this.isDark,
    required this.bg,
    required this.bgSecondary,
    required this.card,
    required this.cardAlt,
    required this.field,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.navBg,
    required this.heroGradient,
  });

  static const dark = AppPalette(
    isDark: true,
    bg: Color(0xFF08080A),
    bgSecondary: Color(0xFF0C0C0F),
    card: Color(0xFF111114),
    cardAlt: Color(0xFF18181D),
    field: Color(0xFF0D0D11),
    border: Color(0xFF23232A),
    text: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    navBg: Color(0xFF0A0A0D),
    heroGradient: LinearGradient(
      colors: [Color(0xFF2E1769), Color(0xFF1A0F3D), Color(0xFF111114)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const light = AppPalette(
    isDark: false,
    bg: Color(0xFFF4F5F9),
    bgSecondary: Color(0xFFEBEDF5),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF1F2F8),
    field: Color(0xFFF7F8FC),
    border: Color(0xFFE2E4EE),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    navBg: Color(0xFFFFFFFF),
    heroGradient: LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFF5B21B6), Color(0xFF431593)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get pal => Theme.of(this).brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
}

ThemeData _buildWith(AppPalette p, Brightness b) {
  final base = ThemeData(brightness: b, useMaterial3: true);
  final interTheme = GoogleFonts.interTextTheme(
    base.textTheme,
  ).apply(bodyColor: p.text, displayColor: p.text);

  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    textTheme: interTheme,
    primaryTextTheme: interTheme,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    colorScheme: ColorScheme(
      brightness: b,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      error: AppColors.red,
      onError: Colors.white,
      surface: p.card,
      onSurface: p.text,
    ),
    dividerTheme: DividerThemeData(color: p.border, space: 1),
    listTileTheme: ListTileThemeData(
      dense: true,
      minVerticalPadding: 4,
      horizontalTitleGap: 10,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
      subtitleTextStyle: GoogleFonts.inter(fontSize: 11, color: p.textMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 46,
      iconTheme: IconThemeData(size: 20, color: p.text),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: p.text,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: p.field,
      hintStyle: GoogleFonts.inter(color: p.textMuted, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      suffixIconConstraints: const BoxConstraints(minHeight: 32, minWidth: 34),
      prefixIconConstraints: const BoxConstraints(minHeight: 32, minWidth: 34),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}

ThemeData buildDarkTheme() => _buildWith(AppPalette.dark, Brightness.dark);

ThemeData buildLightTheme() => _buildWith(AppPalette.light, Brightness.light);

ThemeData buildTheme([Brightness b = Brightness.dark]) =>
    b == Brightness.dark ? buildDarkTheme() : buildLightTheme();
