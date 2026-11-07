import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_error_mapper.dart';

class LinkAccountScreen extends ConsumerStatefulWidget {
  const LinkAccountScreen({super.key});

  @override
  ConsumerState<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends ConsumerState<LinkAccountScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _setLoading(bool value) async {
    if (mounted) {
      setState(() {
        _isLoading = value;
        if (value) {
          _errorMessage = null;
          _successMessage = null;
        }
      });
    }
  }

  Future<void> _handleLinkGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    try {
      await _setLoading(true);
      await repo.linkAnonymousWithGoogle();
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      setState(() => _successMessage = l10n.accountLinkedSuccess);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      if (AuthErrorMapper.isUserCanceled(e)) return;
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() => _errorMessage = AuthErrorMapper.mapException(e, l10n));
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> _handleLinkApple() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    try {
      await _setLoading(true);
      await repo.linkAnonymousWithApple();
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      setState(() => _successMessage = l10n.accountLinkedSuccess);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      if (AuthErrorMapper.isUserCanceled(e)) return;
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() => _errorMessage = AuthErrorMapper.mapException(e, l10n));
    } finally {
      await _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.linkAccount),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
      ),
      body: StadiumPitchBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
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
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.link_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.linkAccountTitle,
                        style: AppTypography.sectionTitle(
                          fontSize: 24,
                          color: isDark
                              ? AppColors.foreground
                              : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.linkAccountSubtitle,
                        style: AppTypography.description(
                          fontSize: 13.5,
                          color: isDark
                              ? AppColors.muted
                              : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (currentUser?.isAnonymous == false)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Text(
                            l10n.accountLinkedSuccess,
                            style: AppTypography.label(
                              fontSize: 13,
                              color: AppColors.success,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: AppTypography.label(
                                        fontSize: 12.5,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
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
                          ),
                        ArenaButton(
                          label: l10n.googleLogin,
                          icon: Icons.g_mobiledata_rounded,
                          isLoading: _isLoading,
                          expand: true,
                          onTap: _handleLinkGoogle,
                        ),
                        const SizedBox(height: 10),
                        SecondaryButton(
                          label: l10n.appleLogin,
                          icon: Icons.apple,
                          expand: true,
                          onTap: _isLoading ? null : _handleLinkApple,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.pop(),
                          child: Text(l10n.cancel),
                        ),
                      ],
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
