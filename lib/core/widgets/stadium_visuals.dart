import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Official Goalverse geometric emblem (Stylized 'G' + tactical pitch/pentagon
/// core) rendered with CustomPaint so it scales crisply at any size.
class GoalverseEmblem extends StatelessWidget {
  final double size;
  final bool showGlow;

  const GoalverseEmblem({super.key, this.size = 56, this.showGlow = true});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.85),
          width: (size * 0.038).clamp(1.4, 2.6),
        ),
        boxShadow: (showGlow && !reduceMotion)
            ? AppShadows.primaryCtaGlow
            : null,
      ),
      child: CustomPaint(painter: _GoalverseEmblemPainter()),
    );
  }
}

class _GoalverseEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final outerRadius = math.min(w, h) * 0.34;

    // Subtle tactical pitch ring inside the emblem
    final pitchRingPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.025).clamp(1.0, 2.0);
    canvas.drawCircle(center, outerRadius * 1.12, pitchRingPaint);

    // Geometric 'G' outer arc in Neon Volt (#C9FD06)
    final gStroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.115).clamp(3.0, 8.0)
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: outerRadius);
    const startAngle = -math.pi * 0.22;
    const sweepAngle = -math.pi * 1.58;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, gStroke);

    // Horizontal crossbar of the 'G' pointing into the center goal spot
    final crossbarPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.11).clamp(2.8, 7.5)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx + outerRadius * 0.05, center.dy),
      Offset(center.dx + outerRadius * 0.96, center.dy),
      crossbarPaint,
    );

    // Center tactical football pentagon / kickoff spot in Arctic Mint
    final coreRadius = outerRadius * 0.26;
    final pentagonPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final pt = Offset(
        center.dx + coreRadius * math.cos(angle),
        center.dy + coreRadius * math.sin(angle),
      );
      if (i == 0) {
        pentagonPath.moveTo(pt.dx, pt.dy);
      } else {
        pentagonPath.lineTo(pt.dx, pt.dy);
      }
    }
    pentagonPath.close();
    canvas.drawPath(
      pentagonPath,
      Paint()
        ..color = AppColors.arcticMint
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Goalverse wordmark pill or header lockup.
class GoalverseWordmark extends StatelessWidget {
  final double fontSize;
  final double emblemSize;
  final String? subtitle;
  final bool centered;

  const GoalverseWordmark({
    super.key,
    this.fontSize = 28,
    this.emblemSize = 44,
    this.subtitle,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        GoalverseEmblem(size: emblemSize, showGlow: false),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: centered
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appBrandUpper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heroDisplay(
                  fontSize: fontSize,
                  color: isDark
                      ? AppColors.foreground
                      : AppColors.lightTextPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    fontSize: 10.5,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Wraps any screen in a deep stadium atmosphere with controlled top radial
/// spotlight and subtle tactical football pitch geometry.
class StadiumPitchBackground extends StatelessWidget {
  final Widget child;
  final Color? spotlightColor;
  final double pitchOpacity;

  const StadiumPitchBackground({
    super.key,
    required this.child,
    this.spotlightColor,
    this.pitchOpacity = 0.045,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) {
      return child;
    }

    final glow = spotlightColor ?? AppColors.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.background),
        Positioned(
          top: -120,
          left: 0,
          right: 0,
          height: 320,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [
                    glow.withValues(alpha: 0.08),
                    AppColors.softViolet.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: _TacticalPitchPainter(
              lineColor: AppColors.foreground.withValues(alpha: pitchOpacity),
              accentColor: glow.withValues(alpha: pitchOpacity * 1.15),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _TacticalPitchPainter extends CustomPainter {
  final Color lineColor;
  final Color accentColor;

  const _TacticalPitchPainter({
    required this.lineColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final w = size.width;
    final h = size.height;

    const margin = 18.0;
    final pitchRect = Rect.fromLTWH(
      margin,
      margin,
      w - margin * 2,
      h - margin * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitchRect, const Radius.circular(28)),
      paint,
    );

    final midY = h * 0.44;
    canvas.drawLine(Offset(margin, midY), Offset(w - margin, midY), paint);

    final center = Offset(w / 2, midY);
    final circleRadius = math.min(w, h) * 0.15;
    canvas.drawCircle(center, circleRadius, accentPaint);
    canvas.drawCircle(
      center,
      3.0,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill,
    );

    final boxWidth = w * 0.50;
    final boxHeight = h * 0.12;
    canvas.drawRect(
      Rect.fromLTWH((w - boxWidth) / 2, margin, boxWidth, boxHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TacticalPitchPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}

// =============================================================================
// DESIGN SYSTEM BUTTONS (ArenaButton, SecondaryButton, IconActionButton)
// =============================================================================

/// Primary Neon Volt CTA button used only for the main screen action.
class ArenaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool compact;
  final bool expand;

  const ArenaButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
    this.compact = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      semanticLabel: label,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 22,
          vertical: compact ? 11 : 15,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.primaryCtaGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primaryText,
                ),
              )
            else if (icon != null) ...[
              Icon(icon, size: compact ? 18 : 21, color: AppColors.primaryText),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.button(
                  fontSize: compact ? 13.5 : 15,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Low-contrast elevated secondary button without neon border clutter.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool compact;
  final bool expand;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.iconColor,
    this.compact = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressableScale(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: compact ? 11 : 15,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceElevated
              : AppColors.lightSurfaceElevated,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: compact ? 17 : 19,
                color:
                    iconColor ??
                    (isDark ? AppColors.foreground : AppColors.lightForeground),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.button(
                  fontSize: compact ? 13 : 14.5,
                  color: isDark
                      ? AppColors.foreground
                      : AppColors.lightForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clean icon button for top header actions.
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final double size;
  final VoidCallback onTap;

  const IconActionButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.size = 40,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.lightBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: size * 0.48,
        color: isDark ? AppColors.foreground : AppColors.lightForeground,
      ),
    );
    return PressableScale(
      semanticLabel: tooltip,
      onTap: onTap,
      child: tooltip != null ? Tooltip(message: tooltip!, child: box) : box,
    );
  }
}

// =============================================================================
// BESPOKE MODE ILLUSTRATIONS FOR ALL 7 GAME MODES (Section 5 & Section 9)
// =============================================================================

/// 1. Football SOS: 3x3 Tactical Grid with glowing diagonal strike line.
class MiniSosGridGraphic extends StatelessWidget {
  final double size;
  const MiniSosGridGraphic({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    const marks = ['X', '', 'O', '', 'X', 'O', 'O', '', 'X'];
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Stack(
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 3.5,
              crossAxisSpacing: 3.5,
            ),
            itemBuilder: (_, i) {
              final m = marks[i];
              final isDiag = i == 0 || i == 4 || i == 8;
              return Container(
                decoration: BoxDecoration(
                  color: isDiag
                      ? AppColors.electricCoral.withValues(alpha: 0.18)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  m,
                  style: AppTypography.scoreLarge(
                    fontSize: size * 0.16,
                    color: m == 'X'
                        ? AppColors.electricCoral
                        : AppColors.arcticMint,
                  ),
                ),
              );
            },
          ),
          // Diagonal winning line overlay
          IgnorePointer(
            child: CustomPaint(
              size: Size(size - 12, size - 12),
              painter: _DiagonalStrikePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalStrikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.14, size.height * 0.14),
      Offset(size.width * 0.86, size.height * 0.86),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. Rating Battle: Overlapping FUT Player Cards (91 vs 89).
class FutMiniCardGraphic extends StatelessWidget {
  final double size;
  const FutMiniCardGraphic({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.15,
            child: Transform.translate(
              offset: const Offset(-11, 3),
              child: _miniCard(
                rating: '89',
                pos: 'ST',
                bg: AppColors.surfaceSecondary,
                border: AppColors.borderStrong,
                textColor: AppColors.foreground,
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.12,
            child: Transform.translate(
              offset: const Offset(11, -2),
              child: _miniCard(
                rating: '91',
                pos: 'CF',
                bg: AppColors.surfaceElevated,
                border: AppColors.arcticMint,
                textColor: AppColors.arcticMint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard({
    required String rating,
    required String pos,
    required Color bg,
    required Color border,
    required Color textColor,
  }) {
    return Container(
      width: 38,
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.3),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rating,
            style: AppTypography.scoreLarge(fontSize: 16, color: textColor),
          ),
          const SizedBox(height: 1),
          Text(
            pos,
            style: AppTypography.label(
              fontSize: 8.5,
              color: textColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Two Teams 1 Player: Interlocking Club Shields with Shared Link Node.
class TwoTeamsBridgeIllustration extends StatelessWidget {
  final double size;
  const TwoTeamsBridgeIllustration({super.key, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 7, child: _clubCircle('RM', AppColors.info)),
          Positioned(right: 7, child: _clubCircle('GS', AppColors.warmAmber)),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.arcticMint, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.link_rounded,
              size: 12,
              color: AppColors.arcticMint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _clubCircle(String code, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: AppTypography.label(fontSize: 8, color: AppColors.foreground),
      ),
    );
  }
}

/// 4. Who Am I?: Mystery Footballer Silhouette with Clue Steps.
class WhoAmISilhouetteIllustration extends StatelessWidget {
  final double size;
  const WhoAmISilhouetteIllustration({super.key, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            bottom: 6,
            child: Icon(
              Icons.person_rounded,
              size: 38,
              color: AppColors.surfaceElevated,
            ),
          ),
          Positioned(
            top: 9,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.warmAmber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.warmAmber, width: 1.3),
              ),
              alignment: Alignment.center,
              child: Text(
                '?',
                style: AppTypography.scoreLarge(
                  fontSize: 14,
                  color: AppColors.warmAmber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Imposter: 2x2 Tactical Grid with 3 Valid Green Nodes & 1 Red Target Node.
class ImposterRadarIllustration extends StatelessWidget {
  final double size;
  const ImposterRadarIllustration({super.key, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_node(isImposter: false), _node(isImposter: false)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_node(isImposter: false), _node(isImposter: true)],
          ),
        ],
      ),
    );
  }

  Widget _node({required bool isImposter}) {
    final color = isImposter ? AppColors.error : AppColors.success;
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Icon(
        isImposter ? Icons.close_rounded : Icons.check_rounded,
        size: 11,
        color: color,
      ),
    );
  }
}

/// 6. Transfer Path: Connected 3-Node Chronological Route Illustration.
class TransferTimelineIllustration extends StatelessWidget {
  final double size;
  const TransferTimelineIllustration({super.key, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: CustomPaint(painter: _TimelineNodePainter()),
    );
  }
}

class _TimelineNodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.2, size.height * 0.78);
    final p2 = Offset(size.width * 0.5, size.height * 0.48);
    final p3 = Offset(size.width * 0.8, size.height * 0.22);

    final linePaint = Paint()
      ..color = AppColors.aiAccent.withValues(alpha: 0.65)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy);
    canvas.drawPath(path, linePaint);

    for (final pt in [p1, p2, p3]) {
      canvas.drawCircle(pt, 4.5, Paint()..color = AppColors.background);
      canvas.drawCircle(
        pt,
        4.0,
        Paint()..color = pt == p3 ? AppColors.primary : AppColors.aiAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 7. Football Bomb: Digital Fuse Timer Arc (`18s`).
class BombCountdownIllustration extends StatelessWidget {
  final double size;
  const BombCountdownIllustration({super.key, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 2.6,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.flameOrange,
              ),
            ),
          ),
          Text(
            '18s',
            style: AppTypography.statValue(
              fontSize: 12.5,
              color: AppColors.flameOrange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Legacy compatibility wrapper if referenced elsewhere.
class ModeBadgeGraphic extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final double size;

  const ModeBadgeGraphic({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Icon(icon, color: accentColor, size: size * 0.48),
    );
  }
}

// =============================================================================
// BROADCAST SCOREBOARD FOR MATCH SCREENS
// =============================================================================
class BroadcastScoreboard extends StatelessWidget {
  final String p1Name;
  final String p1Badge;
  final int p1Score;
  final Color p1Color;
  final bool p1Active;

  final String p2Name;
  final String p2Badge;
  final int p2Score;
  final Color p2Color;
  final bool p2Active;

  final String centerTopLabel;
  final String centerBottomLabel;
  final Color centerAccent;

  const BroadcastScoreboard({
    super.key,
    required this.p1Name,
    required this.p1Badge,
    required this.p1Score,
    this.p1Color = AppColors.primary,
    required this.p1Active,
    required this.p2Name,
    required this.p2Badge,
    required this.p2Score,
    this.p2Color = AppColors.cyberCyan,
    required this.p2Active,
    required this.centerTopLabel,
    required this.centerBottomLabel,
    this.centerAccent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        boxShadow: AppShadows.cardSubtle,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Player 1 Wing
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.cardSelect,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: p1Active
                    ? p1Color.withValues(alpha: 0.12)
                    : AppColors.surfaceElevated,
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: p1Active ? p1Color : Colors.transparent,
                  width: 1.3,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: p1Color,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p1Badge,
                      style: AppTypography.scoreLarge(
                        fontSize: 15,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p1Name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        fontSize: 12.5,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$p1Score',
                    style: AppTypography.scoreLarge(
                      fontSize: 22,
                      color: p1Active ? p1Color : AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Clock / Status Module
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerTopLabel,
                  style: AppTypography.statValue(
                    fontSize: 15,
                    color: centerAccent,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  centerBottomLabel,
                  style: AppTypography.label(
                    fontSize: 9.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          // Player 2 Wing
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.cardSelect,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: p2Active
                    ? p2Color.withValues(alpha: 0.12)
                    : AppColors.surfaceElevated,
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: p2Active ? p2Color : Colors.transparent,
                  width: 1.3,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$p2Score',
                    style: AppTypography.scoreLarge(
                      fontSize: 22,
                      color: p2Active ? p2Color : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p2Name,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        fontSize: 12.5,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: p2Color,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p2Badge,
                      style: AppTypography.scoreLarge(
                        fontSize: 15,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
