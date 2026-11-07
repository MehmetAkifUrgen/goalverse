import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_error_mapper.dart';

/// Full-screen or bottom-sheet Forgot Password flow with email validation,
/// Firebase `sendPasswordResetEmail`, rate-limit handling, and privacy-safe
/// confirmation screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String initialEmail;
  final bool isBottomSheet;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
    this.isBottomSheet = false,
  });

  static Future<void> showSheet(
    BuildContext context, {
    String initialEmail = '',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ForgotPasswordScreen(
          initialEmail: initialEmail,
          isBottomSheet: true,
        ),
      ),
    );
  }

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return l10n.errorInvalidEmail;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return l10n.errorInvalidEmail;
    }
    return null;
  }

  Future<void> _submitReset() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      return;
    }

    final email = _emailController.text.trim();
    final repo = ref.read(authRepositoryProvider);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await repo.sendPasswordResetEmail(email);
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Privacy protection: do not reveal whether a specific email address
      // is registered when Firebase returns user-not-found.
      if (e.code == 'user-not-found') {
        ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
        return;
      }
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() {
        _isLoading = false;
        _errorMessage = AuthErrorMapper.mapException(e, l10n);
      });
    } catch (e) {
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() {
        _isLoading = false;
        _errorMessage = AuthErrorMapper.mapException(e, l10n);
      });
    }
  }

  void _closeOrBack() {
    if (widget.isBottomSheet) {
      Navigator.of(context).pop();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: widget.isBottomSheet
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : AppRadius.largeCardBorder,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: AppMotion.normal,
          child: _emailSent
              ? _buildSuccessView(isDark)
              : _buildFormView(l10n, isDark),
        ),
      ),
    );

    if (widget.isBottomSheet) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Sıfırlama'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _closeOrBack,
        ),
      ),
      body: StadiumPitchBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AppLocalizations l10n, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('forgot_password_form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Şifreni mi Unuttun?',
                      style: AppTypography.modeTitle(
                        fontSize: 22,
                        color: isDark
                            ? AppColors.foreground
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Hesabına ait e-posta adresini gir, şifre sıfırlama bağlantısını gönderelim.',
                      style: AppTypography.description(
                        fontSize: 12.5,
                        color: isDark
                            ? AppColors.muted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isBottomSheet)
                IconActionButton(
                  icon: Icons.close_rounded,
                  size: 36,
                  onTap: _closeOrBack,
                ),
            ],
          ),
          const SizedBox(height: 20),
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
          TextFormField(
            key: const Key('forgot_password_email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitReset(),
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.hintEmail,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) => _validateEmail(v, l10n),
          ),
          const SizedBox(height: 20),
          ArenaButton(
            label: 'Sıfırlama Bağlantısı Gönder',
            icon: Icons.send_rounded,
            isLoading: _isLoading,
            expand: true,
            onTap: _submitReset,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Giriş Ekranına Dön',
            expand: true,
            onTap: _isLoading ? null : _closeOrBack,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    final email = _emailController.text.trim();
    return Column(
      key: const ValueKey('forgot_password_success'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.success,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sıfırlama Bağlantısı Gönderildi',
          textAlign: TextAlign.center,
          style: AppTypography.modeTitle(
            fontSize: 23,
            color: isDark ? AppColors.foreground : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$email adresiyle kayıtlı bir hesap bulunuyorsa şifre sıfırlama bağlantısı gönderildi. Lütfen gelen kutunu ve gereksiz (spam) klasörünü kontrol et.',
          textAlign: TextAlign.center,
          style: AppTypography.description(
            fontSize: 13.5,
            color: isDark ? AppColors.muted : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 22),
        ArenaButton(
          label: 'Giriş Ekranına Dön',
          icon: Icons.login_rounded,
          expand: true,
          onTap: _closeOrBack,
        ),
      ],
    );
  }
}
