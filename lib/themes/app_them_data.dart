import 'package:flutter/material.dart';

class AppThemeData {
  static const Color surface50 = Color(0xFFFFFBF5);
  static const Color surfaceDark50 = Color(0xFF1A1A2E);

  static const Color grey01 = Color(0xFF000000);
  static const Color grey02 = Color(0xFF2D2E2F);
  static const Color grey03 = Color(0xFF6B6D6F);
  static const Color grey04 = Color(0xFF8B8C8D);
  static const Color grey05 = Color(0xFFC8C9CA);
  static const Color grey06 = Color(0xFFE3E3E3);
  static const Color grey07 = Color(0xFFF0F0F0);
  static const Color grey08 = Color(0xFFF0F0F0);
  static const Color grey09 = Color(0xFFF7F7F7);
  static const Color grey10 = Color(0xFFFFFFFF);

  static const Color greyDark01 = Color(0xFFFFFFFF);
  static const Color greyDark02 = Color(0xFFF7F7F7);
  static const Color greyDark03 = Color(0xFFF0F0F0);
  static const Color greyDark04 = Color(0xFFF0F0F0);
  static const Color greyDark05 = Color(0xFFE3E3E3);
  static const Color greyDark06 = Color(0xFFC8C9CA);
  static const Color greyDark07 = Color(0xFF8B8C8D);
  static const Color greyDark08 = Color(0xFF6B6D6F);
  static const Color greyDark09 = Color(0xFF242628);
  static const Color greyDark10 = Color(0xFF000000);

  static const Color red01 = Color(0xFFFA4D4D);
  static Color red02 = Color(0xFFFFC107);
  static const Color red03 = Color(0xFFFFECEC);

  static const Color redDark01 = Color(0xFFFFECEC);
  static Color redDark02 = Color(0xFFFFC107);
  static const Color redDark03 = Color(0xFFFA4D4D);

  static const Color orange01 = Color(0xFFFF6B35);
  static const Color orange02 = Color(0xFFFF8C42);
  static const Color orange03 = Color(0xFFFFE5D9);

  static const Color orangeDark01 = Color(0xFFFFE5D9);
  static const Color orangeDark02 = Color(0xFFFF8C42);
  static const Color orangeDark03 = Color(0xFFFF6B35);

  static const Color lime01 = Color(0xFF7FD957);
  static const Color lime02 = Color(0xFF5CB85C);
  static const Color lime03 = Color(0xFFE8F8E5);

  static const Color limeDark01 = Color(0xFFE8F8E5);
  static const Color limeDark02 = Color(0xFF5CB85C);
  static const Color limeDark03 = Color(0xFF7FD957);

  static const Color green01 = Color(0xFF4CAF50);
  static const Color green02 = Color(0xFF45A049);
  static const Color green03 = Color(0xFFE8F5E9);

  static const Color greenDark01 = Color(0xFFE8F5E9);
  static const Color greenDark02 = Color(0xFF45A049);
  static const Color greenDark03 = Color(0xFF4CAF50);

  static const Color teal01 = Color(0xFF26C6DA);
  static const Color teal02 = Color(0xFF00ACC1);
  static const Color teal03 = Color(0xFFE0F7FA);

  static const Color tealDark01 = Color(0xFF26C6DA);
  static const Color tealDark02 = Color(0xFF00ACC1);
  static const Color tealDark03 = Color(0xFF26C6DA);

  static const Color blue01 = Color(0xFF5C6BC0);
  static const Color blue02 = Color(0xFF3F51B5);
  static const Color blue03 = Color(0xFFE8EAF6);

  static const Color blueDark01 = Color(0xFFE8EAF6);
  static const Color blueDark02 = Color(0xFF3F51B5);
  static const Color blueDark03 = Color(0xFF5C6BC0);

  static const Color primary = Color(0xFFFF6B9D);
  static const Color primaryLight = Color(0xFFFFB3C6);
  static const Color primaryDark = Color(0xFFE91E63);

  static const Color secondary = Color(0xFFFFA726);
  static const Color secondaryLight = Color(0xFFFFD54F);
  static const Color secondaryDark = Color(0xFFF57C00);

  static const Color accent = Color(0xFF66BB6A);
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF388E3C);

  static const Color yellow = Color(0xFFFFEB3B);
  static const Color yellowLight = Color(0xFFFFF59D);
  static const Color yellowDark = Color(0xFFFBC02D);

  static const Color purple = Color(0xFFAB47BC);
  static const Color purpleLight = Color(0xFFCE93D8);
  static const Color purpleDark = Color(0xFF7B1FA2);

  static LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFFEB3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF26C6DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient vibrantGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFFA726), Color(0xFFFFEB3B), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const String regular = 'Poppins-Regular';
  static const String medium = 'Poppins-Medium';
  static const String bold = 'Poppins-Bold';
  static const String semibold = 'Poppins-SemiBold';
  static const String extraBold = 'Poppins-ExtraBold';

  static const String regularOpenSans = 'OpenSans-Regular';
  static const String mediumOpenSans = 'OpenSans-Medium';
  static const String boldOpenSans = 'OpenSans-Bold';
  static const String semiboldOpenSans = 'OpenSans-SemiBold';
  static const String extraBoldOpenSans = 'OpenSans-ExtraBold';
}
