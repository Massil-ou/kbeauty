import 'package:flutter/material.dart';

class KBeautyTheme {
  static const primary = Color(0xFFB34874);
  static const primaryDark = Color(0xFF702344);
  static const primaryLight = Color(0xFFD986A9);
  static const primarySoft = Color(0xFFFBEAF1);

  static const lilac = Color(0xFF8B5CF6);
  static const lilacSoft = Color(0xFFF2ECFF);
  static const gold = Color(0xFFC8913A);
  static const goldSoft = Color(0xFFFFF5DF);

  static const text = Color(0xFF261C22);
  static const muted = Color(0xFF776B72);
  static const background = Color(0xFFFFF9FB);
  static const surface = Color(0xFFFFFFFF);
  static const divider = Color(0xFFF0DFE7);
  static const success = Color(0xFF268766);
  static const danger = Color(0xFFC43C5C);

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: lilac,
        tertiary: gold,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text,
      ),
      cardColor: surface,
      dividerColor: divider,
      fontFamily: null,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryLight.withValues(alpha: 0.45),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primaryDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: surface,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
        shape: Border(bottom: BorderSide(color: divider)),
        titleTextStyle: TextStyle(
          color: primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: divider),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      );

  static BoxDecoration softDecoration({
    double radius = 16,
    Color color = primarySoft,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      );
}

class KBeautyBackdrop extends StatelessWidget {
  const KBeautyBackdrop({super.key, this.strong = false});

  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/back.png', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: strong
                  ? [
                      KBeautyTheme.primaryDark.withValues(alpha: 0.84),
                      KBeautyTheme.primary.withValues(alpha: 0.70),
                      KBeautyTheme.lilac.withValues(alpha: 0.58),
                    ]
                  : [
                      KBeautyTheme.surface.withValues(alpha: 0.94),
                      KBeautyTheme.background.withValues(alpha: 0.82),
                      KBeautyTheme.primarySoft.withValues(alpha: 0.82),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
