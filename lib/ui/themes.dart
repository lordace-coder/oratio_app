import 'package:flutter/material.dart';

class AppColors {
  static Color primary = const Color(0xff0CC1E0);
  static Color dimGray = const Color(0xffD9D9D9).withOpacity(28 / 100);
  static Color gray = const Color(0xffD9D9D9);
  static Color textDim = Colors.white.withOpacity(.5);
  static Color textDarkDim = Colors.black.withOpacity(.5);
  static Color appBg = const Color(0xffF6F8F9);
  static Color inputBoxGray = const Color(0xffECECEC);
  static Color green = const Color(0xff00C33A);
  static Color greenDisabled = const Color(0xff00C33A).withOpacity(.5);
  static Color blueDim = const Color(0xff0F91D7).withOpacity(.2);
  static Color blue = const Color(0xff0F91D7);
  static Color warning = const Color.fromARGB(255, 223, 186, 17);
  static Color purple = const Color(0xFF4A184C);
  static Color purpleLight = const Color(0xFF6B2A6E);
  static Color cardBg = Colors.white;
  static Color shadow = Colors.black12;
  static Color accent = const Color(0xFFFFA726);
  static Color success = const Color(0xFF4CAF50);
  static Color error = const Color(0xFFE53935);
  static Color pending = const Color(0xFFFF9800);
  static LinearGradient primaryGradient = LinearGradient(
    colors: [const Color(0xFF8E2DE2), AppColors.primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
