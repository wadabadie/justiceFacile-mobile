import 'package:flutter/material.dart';

abstract final class AppColors {
  static const or         = Color(0xFFC9920A);
  static const orPale     = Color(0xFFF5D98B);
  static const orLight    = Color(0xFFFFF4D6);
  static const orDark     = Color(0xFF9A6D06);

  static const bleuNuit   = Color(0xFF1A2E4A);
  static const bleuMid    = Color(0xFF243F63);
  static const bleuLight  = Color(0xFF2E5480);

  static const emeraude      = Color(0xFF0F7B72);
  static const emeraudeLight = Color(0xFFE8F5F4);

  static const rouge      = Color(0xFFC0392B);
  static const rougeLight = Color(0xFFFDECEA);

  static const gris       = Color(0xFF2C3E50);
  static const grisMid    = Color(0xFF657280);
  static const grisLight  = Color(0xFFB0BEC5);

  static const fond       = Color(0xFFF8F6F0);
  static const fond2      = Color(0xFFF0EDE4);
  static const blanc      = Color(0xFFFFFFFF);

  static const gradientOr = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [or, orDark],
  );

  static const gradientBleu = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bleuNuit, bleuMid],
  );

  static const gradientSplash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bleuNuit, Color(0xFF0D1E35), Color(0xFF091525)],
    stops: [0.0, 0.6, 1.0],
  );

  static const ombreOr = BoxShadow(
    color: Color(0x40C9920A),
    blurRadius: 24,
    offset: Offset(0, 6),
  );

  static const ombre = BoxShadow(
    color: Color(0x1E1A2E4A),
    blurRadius: 32,
    offset: Offset(0, 8),
  );
}
