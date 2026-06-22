import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light/dark theme — Academic Insight Logic.
class AppTheme {
  AppTheme._();

  static const _radius = 12.0;

  static ThemeData get lightTheme {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.surfaceMuted,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.surfaceMuted,
      onSecondaryContainer: AppColors.primary,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.surfaceSubtle,
      error: AppColors.error,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primary,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.neutral,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.white : AppColors.neutral,
            size: 22,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.primary),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        showCheckmark: false,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: AppColors.textSecondary, height: 1.45),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelSmall: TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.white,
      onPrimary: AppColors.primary,
      primaryContainer: Color(0xFF243B53),
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      surface: AppColors.darkBackground,
      onSurface: AppColors.white,
      onSurfaceVariant: Color(0xFF94A3B8),
      outline: Color(0xFF334155),
      outlineVariant: Color(0xFF1E293B),
      error: AppColors.error,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    );
  }
}
