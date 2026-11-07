import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Centralized animation durations, curves, haptic feedback, and interactive
/// motion widgets for the Goalverse design system (Section 8: Motion Design).
class AppMotion {
  AppMotion._();

  // Core motion durations
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration buttonPress = Duration(milliseconds: 120);
  static const Duration cardSelect = Duration(milliseconds: 200);
  static const Duration pageTransition = Duration(
    milliseconds: 290,
  ); // 250-350ms
  static const Duration answerFeedback = Duration(milliseconds: 240);
  static const Duration scoreCounter = Duration(milliseconds: 520);
  static const Duration xpFill = Duration(milliseconds: 600);
  static const Duration rewardAnimation = Duration(milliseconds: 680);
  static const Duration entranceDuration = Duration(milliseconds: 360);
  static const Duration staggerStep = Duration(milliseconds: 50);

  // Standard curves
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve entranceCurve = Curves.easeOutQuart;
  static const Curve emphasizedCurve = Curves.easeOutBack;
  static const Curve pressCurve = Curves.easeInOutCubic;

  /// Returns Duration.zero if the user has enabled Reduce Motion in OS settings.
  static Duration effectiveDuration(BuildContext context, Duration duration) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return disableAnimations ? Duration.zero : duration;
  }
}

/// Centralized Haptic Feedback helpers for Goalverse interactions.
class AppHaptics {
  AppHaptics._();

  static void buttonTap() => HapticFeedback.selectionClick();
  static void correctAnswer() => HapticFeedback.lightImpact();
  static void wrongAnswer() => HapticFeedback.heavyImpact();
  static void matchFound() => HapticFeedback.mediumImpact();
  static void rewardReceived() => HapticFeedback.mediumImpact();
}

/// Interactive wrapper that provides tactile scale (0.97) + subtle opacity
/// feedback on press, respects Reduce Motion, and triggers haptic feedback.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double pressedOpacity;
  final Duration duration;
  final BorderRadius? borderRadius;
  final bool enableHaptic;
  final String? semanticLabel;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.93,
    this.duration = AppMotion.buttonPress,
    this.borderRadius,
    this.enableHaptic = true,
    this.semanticLabel,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value || !mounted) return;
    setState(() => _isPressed = value);
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) {
      AppHaptics.buttonTap();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final effectiveDuration = disableAnimations
        ? Duration.zero
        : widget.duration;
    final activePress = _isPressed && !disableAnimations;

    Widget content = AnimatedScale(
      scale: activePress ? widget.pressedScale : 1.0,
      duration: effectiveDuration,
      curve: AppMotion.pressCurve,
      child: AnimatedOpacity(
        opacity: activePress ? widget.pressedOpacity : 1.0,
        duration: effectiveDuration,
        curve: AppMotion.pressCurve,
        child: widget.child,
      ),
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        button: true,
        enabled: widget.onTap != null,
        label: widget.semanticLabel,
        child: content,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null ? (_) => _setPressed(true) : null,
      onTapUp: widget.onTap != null ? (_) => _setPressed(false) : null,
      onTapCancel: widget.onTap != null ? () => _setPressed(false) : null,
      onTap: widget.onTap != null ? _handleTap : null,
      child: content,
    );
  }
}

/// Smooth staggered fade + slide entrance animation for screen sections and cards.
/// Automatically skips animation when Reduce Motion is enabled.
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delayStep;
  final Offset beginOffset;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppMotion.entranceDuration,
    this.delayStep = AppMotion.staggerStep,
    this.beginOffset = const Offset(0, 0.04),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.entranceCurve,
    );
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.entranceCurve),
    );

    final delayMs = widget.index * widget.delayStep.inMilliseconds;
    if (delayMs <= 0) {
      _controller.forward();
    } else {
      _delayTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Animated numeric scoreboard counter using Space Grotesk tabular figures.
class AnimatedScoreText extends StatelessWidget {
  final int value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedScoreText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = AppMotion.scoreCounter,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = AppMotion.effectiveDuration(context, duration);
    final baseStyle = style ?? AppTypography.numericMedium();
    final tabularStyle = baseStyle.copyWith(
      fontFeatures: AppTypography.tabularFigures,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value.toDouble(), end: value.toDouble()),
      duration: effectiveDuration,
      curve: AppMotion.standardCurve,
      builder: (context, animatedValue, _) {
        return Text(
          '$prefix${animatedValue.round()}$suffix',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tabularStyle,
        );
      },
    );
  }
}

/// Smoothly animated XP / progress bar with Reduce Motion support.
class SmoothProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color color;
  final Color? backgroundColor;

  const SmoothProgressBar({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.color = AppColors.arcticMint,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final duration = AppMotion.effectiveDuration(context, AppMotion.xpFill);

    return ClipRRect(
      borderRadius: AppRadius.pillBorder,
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: clamped, end: clamped),
          duration: duration,
          curve: AppMotion.standardCurve,
          builder: (context, val, _) {
            return LinearProgressIndicator(
              value: val,
              backgroundColor:
                  backgroundColor ??
                  AppColors.surfaceSecondary.withValues(alpha: 0.9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            );
          },
        ),
      ),
    );
  }
}

/// Countdown badge that highlights and scales subtly during the final 5 seconds.
class CountdownTimerPill extends StatelessWidget {
  final int secondsLeft;
  final int criticalThreshold;

  const CountdownTimerPill({
    super.key,
    required this.secondsLeft,
    this.criticalThreshold = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = secondsLeft <= criticalThreshold && secondsLeft > 0;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final accent = isCritical ? AppColors.error : AppColors.arcticMint;

    return AnimatedScale(
      scale: (isCritical && !disableAnimations) ? 1.06 : 1.0,
      duration: AppMotion.fast,
      curve: AppMotion.emphasizedCurve,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isCritical ? 0.22 : 0.14),
          borderRadius: AppRadius.pillBorder,
          border: Border.all(
            color: accent.withValues(alpha: isCritical ? 0.85 : 0.45),
            width: isCritical ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCritical ? Icons.timer_rounded : Icons.schedule_rounded,
              size: 15,
              color: accent,
            ),
            const SizedBox(width: 5),
            Text(
              '${secondsLeft}s',
              style: AppTypography.numericMedium(fontSize: 14, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
