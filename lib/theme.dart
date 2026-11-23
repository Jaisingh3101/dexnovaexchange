import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void toggleTheme() {
  final nextDark = themeNotifier.value != ThemeMode.dark;
  themeNotifier.value = nextDark ? ThemeMode.dark : ThemeMode.light;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: nextDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: nextDark ? Brightness.dark : Brightness.light,
    ),
  );
}

class AppColors {
  static const bg = Color(0xFF07050F);
  static const card = Color(0xFF100C1E);
  static const cardLight = Color(0xFF17122B);
  static const border = Color(0xFF251C40);
  static const primary = Color(0xFF7B3FF2);
  static const primaryLight = Color(0xFF9D6BFF);
  static const primaryDark = Color(0xFF5B21D6);
  static const green = Color(0xFF16C784);
  static const red = Color(0xFFEA3943);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const textMuted = Color(0xFF847D9E);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF8B4DFF), Color(0xFF5B21D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const balanceGradient = LinearGradient(
    colors: [Color(0xFF2A1560), Color(0xFF170D35), Color(0xFF120A28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

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
    bg: Color(0xFF07050F),
    bgSecondary: Color(0xFF0B0816),
    card: Color(0xFF100C1E),
    cardAlt: Color(0xFF17122B),
    field: Color(0xFF140F26),
    border: Color(0xFF251C40),
    text: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFB8B2CC),
    textMuted: Color(0xFF847D9E),
    navBg: Color(0xFF0B0816),
    heroGradient: LinearGradient(
      colors: [Color(0xFF2E1769), Color(0xFF1A0F3D), Color(0xFF120A28)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const light = AppPalette(
    isDark: false,
    bg: Color(0xFFF4F6FB),
    bgSecondary: Color(0xFFECEFF8),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF1EFFB),
    field: Color(0xFFF5F4FA),
    border: Color(0xFFE2DFF0),
    text: Color(0xFF120E24),
    textSecondary: Color(0xFF4B4563),
    textMuted: Color(0xFF7A7394),
    navBg: Color(0xFFFFFFFF),
    heroGradient: LinearGradient(
      colors: [Color(0xFF6B35E8), Color(0xFF4F22C4), Color(0xFF3E18A3)],
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
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
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
      titleTextStyle: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
      subtitleTextStyle: TextStyle(fontSize: 11.5, color: p.textMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 46,
      iconTheme: IconThemeData(size: 20, color: p.text),
      titleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: p.text,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: const TextStyle(fontSize: 12.5, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: p.field,
      hintStyle: TextStyle(color: p.textMuted, fontSize: 12.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      suffixIconConstraints: const BoxConstraints(minHeight: 34, minWidth: 36),
      prefixIconConstraints: const BoxConstraints(minHeight: 34, minWidth: 36),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}

ThemeData buildDarkTheme() => _buildWith(AppPalette.dark, Brightness.dark);

ThemeData buildLightTheme() => _buildWith(AppPalette.light, Brightness.light);

ThemeData buildTheme([Brightness b = Brightness.dark]) =>
    b == Brightness.dark ? buildDarkTheme() : buildLightTheme();
