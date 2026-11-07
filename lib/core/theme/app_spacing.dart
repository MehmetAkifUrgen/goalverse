import 'package:flutter/widgets.dart';

/// Centralized spacing tokens (4, 8, 12, 16, 20, 24, 32, 40).
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;

  static const double xxs = s4;
  static const double xs = s8;
  static const double sm = s12;
  static const double md = s16;
  static const double lg = s20;
  static const double xl = s24;
  static const double xxl = s32;
  static const double xxxl = s40;
  static const double sectionGap = s24;

  static const double screenHorizontal = 16.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: 16.0,
  );
}
