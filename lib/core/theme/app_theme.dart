import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static TextTheme _buildTextTheme(TextTheme base) {
    // configuración de las fuentes y estilos de texto del proyecto
    final montserratTheme = GoogleFonts.montserratTextTheme(base);
    return montserratTheme.copyWith(
      displayLarge: montserratTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      displayMedium: montserratTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      displaySmall: montserratTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: montserratTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: montserratTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: montserratTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleLarge: montserratTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleMedium: montserratTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleSmall: montserratTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      labelLarge: montserratTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ThemeData get lightTheme {
    // definición del tema claro
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.pharmacyGreen,
        brightness: Brightness.light,
        surface: AppColors.lightBackground,
      ),
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    // definición del tema oscuro
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.pharmacyGreen,
        brightness: Brightness.dark,
        surface: AppColors.darkBackground,
      ),
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
      ),
    );
  }
}
