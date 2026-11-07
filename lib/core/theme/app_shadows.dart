import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Controlled elevation and subtle focal shadows for Goalverse cards.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> cardSubtle = [
    BoxShadow(color: Color(0x380A0B16), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x520A0B16), blurRadius: 26, offset: Offset(0, 12)),
  ];

  static List<BoxShadow> primaryCtaGlow = [
    BoxShadow(
      color: AppColors.electricCoral.withValues(alpha: 0.26),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> mintGlow = [
    BoxShadow(
      color: AppColors.arcticMint.withValues(alpha: 0.22),
      blurRadius: 16,
      offset: const Offset(0, 5),
    ),
  ];

  static const List<BoxShadow> card = cardSubtle;
  static const List<BoxShadow> hero = elevated;
}
