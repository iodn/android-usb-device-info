import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light({ColorScheme? dynamicScheme}) {
    final base = dynamicScheme != null
        ? ThemeData(useMaterial3: true, colorScheme: dynamicScheme)
        : ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7DFF)),
            brightness: Brightness.light,
          );

    final cs = base.colorScheme;
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(centerTitle: false, surfaceTintColor: Colors.transparent),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withOpacity(0.5), thickness: 1),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
      ).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static ThemeData dark({ColorScheme? dynamicScheme}) {
    final base = dynamicScheme != null
        ? ThemeData(useMaterial3: true, colorScheme: dynamicScheme)
        : ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E7DFF),
              brightness: Brightness.dark,
            ),
            brightness: Brightness.dark,
          );

    final cs = base.colorScheme;
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(centerTitle: false, surfaceTintColor: Colors.transparent),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withOpacity(0.5), thickness: 1),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
      ).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
