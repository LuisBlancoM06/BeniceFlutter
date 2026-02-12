import 'package:flutter/material.dart';

class AppTheme {
  // ==================== COLORES (idénticos a la web) ====================
  // Primary: purple
  static const Color primaryColor = Color(0xFF7E22CE); // purple-700
  static const Color primaryLight = Color(0xFFA855F7); // purple-500
  static const Color primaryDark = Color(0xFF6B21A8); // purple-800
  static const Color primaryDarker = Color(0xFF581C87); // purple-900

  // Secondary/Accent: orange
  static const Color secondaryColor = Color(0xFFF97316); // orange-500
  static const Color secondaryLight = Color(0xFFFB923C); // orange-400
  static const Color secondaryDark = Color(0xFFEA580C); // orange-600

  // Gradientes (web)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7E22CE), Color(0xFF9333EA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradientDog = LinearGradient(
    colors: [Color(0xCC581C87), Colors.transparent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradientCat = LinearGradient(
    colors: [Color(0xCCC2410C), Colors.transparent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradientFav = LinearGradient(
    colors: [Color(0xCC1F2937), Colors.transparent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient adminSidebarGradient = LinearGradient(
    colors: [Color(0xFF581C87), Color(0xFF6B21A8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Colores de texto
  static const Color textPrimary = Color(0xFF1F2937); // gray-800
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color textLight = Color(0xFF9CA3AF); // gray-400

  // Colores de fondo
  static const Color backgroundColor = Color(0xFFF9FAFB); // gray-50
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color footerColor = Color(0xFF111827); // gray-900
  static const Color footerBorderColor = Color(0xFF1F2937); // gray-800

  // Colores de estado
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Border radius
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 24.0;
  static const double borderRadiusFull = 999.0;

  // Espaciado
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Sombras
  static BoxShadow get shadowSm => BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== THEME DATA ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(color: textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: textSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor.withValues(alpha: 0.1),
        labelStyle: const TextStyle(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusFull),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
      ),
    );
  }
}
