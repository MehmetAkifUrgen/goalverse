import 'package:flutter/widgets.dart';

/// Centralized corner radius tokens:
/// Small: 10, Medium: 16, Large: 22, Extra Large: 28, Pill: 999.
class AppRadius {
  AppRadius._();

  static const double xs = 10.0;
  static const double sm = 10.0; // Small: 10
  static const double md = 16.0; // Medium: 16
  static const double lg = 22.0; // Large: 22
  static const double xl = 28.0; // Extra Large: 28
  static const double hero = 28.0;
  static const double pill = 999.0; // Pill: 999

  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderHero => BorderRadius.circular(hero);
  static BorderRadius get borderPill => BorderRadius.circular(pill);

  static BorderRadius get cardBorder => borderMd;
  static BorderRadius get largeCardBorder => borderLg;
  static BorderRadius get heroBorder => borderHero;
  static BorderRadius get pillBorder => borderPill;
}
