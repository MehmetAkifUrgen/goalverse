import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_error_mapper.dart';

/// Email verification screen for newly registered or unverified email/password
/// accounts. Supports resend with a 60s cooldown, manual reload check, and
/// automatic verification polling on app lifecycle resume.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _resending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCooldown(45);
    _autoCheckTimer = Timer.periodic(
      const Duration(seconds: 6),
      (_) => _checkVerificationSilent(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerificationSilent();
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _checkVerificationSilent() async {
    if (_checking || !mounted) return;
    try {
      final repo = ref.read(authRepositoryProvider);
      final updated = await repo.reloadUser();
      if (!mounted) return;
      if (updated != null && !updated.requiresEmailVerification) {
        ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
        context.go('/home');
      }
    } catch (_) {}
  }

  Future<void> _handleManualCheck() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _checking = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final updated = await repo.reloadUser();
      if (!mounted) return;
      if (updated != null && !updated.requiresEmailVerification) {
        ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
        context.go('/home');
        return;
      }
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() {
        _checking = false;
        _errorMessage =
            'E-posta adresin henüz doğrulanmamış görünüyor. Lütfen e-postadaki bağlantıya tıklayıp tekrar kontrol et.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _errorMessage = AuthErrorMapper.mapException(e, l10n);
      });
    }
  }

  Future<void> _handleResendEmail() async {
    if (_cooldownSeconds > 0 || _resending) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _resending = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      setState(() {
        _resending = false;
        _statusMessage =
            'Doğrulama e-postası tekrar gönderildi! Gelen kutunu kontrol et.';
      });
      _startCooldown(60);
    } catch (e) {
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() {
        _resending = false;
        _errorMessage = AuthErrorMapper.mapException(e, l10n);
      });
    }
  }

  Future<void> _handleSignOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = user?.email ?? '';

    return Scaffold(
      body: StadiumPitchBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: AppRadius.largeCardBorder,
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                    ),
                    boxShadow: isDark ? AppShadows.card : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: AppColors.primary,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'E-posta Adresini Doğrula',
                        textAlign: TextAlign.center,
                        style: AppTypography.sectionTitle(
                          fontSize: 26,
                          color: isDark
                              ? AppColors.foreground
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email.isNotEmpty
                            ? '$email adresine bir doğrulama bağlantısı gönderdik. Hesabını güvene almak ve devam etmek için bağlantıya tıkla.'
                            : 'E-posta adresine bir doğrulama bağlantısı gönderdik. Devam etmek için gelen kutundaki bağlantıya tıkla.',
                        textAlign: TextAlign.center,
                        style: AppTypography.description(
                          fontSize: 13.5,
                          color: isDark
                              ? AppColors.muted
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (_statusMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  style: AppTypography.label(
                                    fontSize: 12.5,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTypography.label(
                                    fontSize: 12.5,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ArenaButton(
                        label: 'Doğruladım, Durumu Kontrol Et',
                        icon: Icons.verified_rounded,
                        isLoading: _checking,
                        expand: true,
                        onTap: _handleManualCheck,
                      ),
                      const SizedBox(height: 10),
                      SecondaryButton(
                        label: _cooldownSeconds > 0
                            ? 'Tekrar Gönder (${_cooldownSeconds}s)'
                            : 'Doğrulama E-postasını Tekrar Gönder',
                        icon: Icons.refresh_rounded,
                        expand: true,
                        onTap: (_cooldownSeconds > 0 || _resending)
                            ? null
                            : _handleResendEmail,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _handleSignOut,
                        icon: const Icon(Icons.logout_rounded, size: 17),
                        label: const Text('Farklı Bir Hesapla Giriş Yap'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
