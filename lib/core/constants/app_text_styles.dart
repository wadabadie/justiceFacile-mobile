import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _f = 'GoogleSans';

  static const splash = TextStyle(
    fontFamily: _f, fontSize: 37, fontWeight: FontWeight.w700,
    color: AppColors.blanc, letterSpacing: -1, height: 1.1,
  );
  static const splashAccent = TextStyle(
    fontFamily: _f, fontSize: 37, fontWeight: FontWeight.w700,
    color: AppColors.orPale, letterSpacing: -1, height: 1.1,
  );
  static const tagline = TextStyle(
    fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w500,
    color: Color(0x8CFFFFFF), letterSpacing: 2,
  );

  static const h1 = TextStyle(
    fontFamily: _f, fontSize: 27, fontWeight: FontWeight.w700,
    color: AppColors.bleuNuit, letterSpacing: -0.5,
  );
  static const h1White = TextStyle(
    fontFamily: _f, fontSize: 27, fontWeight: FontWeight.w700,
    color: AppColors.blanc, letterSpacing: -0.5,
  );
  static const h2 = TextStyle(
    fontFamily: _f, fontSize: 23, fontWeight: FontWeight.w700,
    color: AppColors.bleuNuit,
  );
  static const h3 = TextStyle(
    fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.bleuNuit,
  );

  static const body = TextStyle(
    fontFamily: _f, fontSize: 19, fontWeight: FontWeight.w400,
    color: AppColors.gris, height: 1.55,
  );
  static const bodyWhite = TextStyle(
    fontFamily: _f, fontSize: 18, fontWeight: FontWeight.w400,
    color: Color(0xA6FFFFFF), height: 1.55,
  );
  static const bodySm = TextStyle(
    fontFamily: _f, fontSize: 17, fontWeight: FontWeight.w400,
    color: AppColors.grisMid,
  );

  static const label = TextStyle(
    fontFamily: _f, fontSize: 19, fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  static const labelSm = TextStyle(
    fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.grisMid, letterSpacing: 0.3,
  );

  static const btn = TextStyle(
    fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const inputLabel = TextStyle(
    fontFamily: _f, fontSize: 17, fontWeight: FontWeight.w600,
    color: AppColors.gris, letterSpacing: 0.2,
  );
}
