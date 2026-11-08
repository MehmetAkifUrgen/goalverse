import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_error_mapper.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool initialRegisterMode;

  const LoginScreen({super.key, this.initialRegisterMode = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late bool _isCreateMode;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _isCreateMode = widget.initialRegisterMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setLoading(bool value) async {
    if (mounted) {
      setState(() {
        _isLoading = value;
        if (value) _errorMessage = null;
      });
    }
  }

  void _switchMode(bool createMode) {
    if (_isLoading || _isCreateMode == createMode) return;
    setState(() {
      _isCreateMode = createMode;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  String? _validateName(String? value) {
    if (!_isCreateMode) return null;
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < 2) {
      return 'Lütfen adınızı ve soyadınızı girin (en az 2 karakter).';
    }
    return null;
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

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty || value.length < 6) {
      return '${l10n.errorWeakPassword} (En az 6 karakter)';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isCreateMode) return null;
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi tekrar girin.';
    }
    if (value != _passwordController.text) {
      return 'Şifreler birbiriyle eşleşmiyor.';
    }
    return null;
  }

  Future<void> _handleSignInAnonymously() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    try {
      await _setLoading(true);
      await repo.signInAnonymously();
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
    } catch (e) {
      if (!mounted) return;
      if (!AuthErrorMapper.isUserCanceled(e)) {
        ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
        setState(() => _errorMessage = AuthErrorMapper.mapException(e, l10n));
      }
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    try {
      await _setLoading(true);
      await repo.signInWithGoogle();
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
    } catch (e) {
      if (!mounted) return;
      // Silent return when user cancels Google account picker
      if (AuthErrorMapper.isUserCanceled(e)) {
        return;
      }
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() => _errorMessage = AuthErrorMapper.mapException(e, l10n));
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> _handleSignInWithApple() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    try {
      await _setLoading(true);
      await repo.signInWithApple();
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
    } catch (e) {
      if (!mounted) return;
      if (AuthErrorMapper.isUserCanceled(e)) {
        return;
      }
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() => _errorMessage = AuthErrorMapper.mapException(e, l10n));
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> _handleEmailSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      return;
    }

    if (_isCreateMode && !_acceptedTerms) {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() {
        _errorMessage =
            'Hesap oluşturmak için Kullanım Koşulları ve Gizlilik Politikasını onaylamalısınız.';
      });
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final repo = ref.read(authRepositoryProvider);

    try {
      await _setLoading(true);
      if (_isCreateMode) {
        await repo.createUserWithEmailAndPassword(
          email,
          password,
          displayName: name,
        );
        ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
        if (mounted) {
          context.go('/verify-email');
        }
      } else {
        await repo.signInWithEmailAndPassword(email, password);
        ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      }
    } catch (e) {
      if (!mounted) return;
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() => _errorMessage = AuthErrorMapper.mapException(e, l10n));
    } finally {
      await _setLoading(false);
    }
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Goalverse Kullanım Koşulları ve Gizlilik'),
        content: const SingleChildScrollView(
          child: Text(
            'Goalverse Kullanım Koşulları:\n\n'
            '1. Hesap Güvenliği: E-posta ve şifre bilgileriniz Firebase Authentication güvencesiyle saklanır; şifreleriniz hiçbir zaman veritabanında açık metin olarak tutulmaz.\n\n'
            '2. Oyun Verileri: ELO puanınız, galibiyet seriniz ve profil adınız liderlik tablosu ve çok oyunculu maç eşleşmeleri için kullanılır.\n\n'
            '3. Hesap Silme: Ayarlar ekranından istediğiniz zaman hesabınızı ve ilişkili tüm profil verilerinizi kalıcı olarak silebilirsiniz.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _acceptedTerms = true;
                _errorMessage = null;
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Okudum, Onaylıyorum'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        final loc = GoRouterState.of(context).matchedLocation;
        if (loc == '/auth') {
          if (user.requiresEmailVerification) {
            context.go('/verify-email');
          } else {
            context.go('/home');
          }
        }
      }
    });

    return Scaffold(
      body: StadiumPitchBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Stadium Hero Header
                    StaggeredEntrance(
                      index: 0,
                      child: _AuthHeroHeader(isDark: isDark),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 2. Main Auth Card (Login / Register Tabs + Form)
                    StaggeredEntrance(
                      index: 1,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surface
                              : AppColors.lightSurface,
                          borderRadius: AppRadius.largeCardBorder,
                          border: Border.all(
                            color: isDark
                                ? AppColors.border
                                : AppColors.lightBorder,
                          ),
                          boxShadow: isDark ? AppShadows.card : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Segmented Mode Toggle (Giriş Yap / Hesap Oluştur)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceSubtle
                                    : AppColors.lightSurfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.lightBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _ModeTabButton(
                                      key: const Key('auth_tab_login'),
                                      label: l10n.login,
                                      selected: !_isCreateMode,
                                      onTap: () => _switchMode(false),
                                    ),
                                  ),
                                  Expanded(
                                    child: _ModeTabButton(
                                      key: const Key('auth_tab_register'),
                                      label: l10n.createAccount,
                                      selected: _isCreateMode,
                                      onTap: () => _switchMode(true),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Error Banner
                            if (_errorMessage != null)
                              Container(
                                key: const Key('auth_error_banner'),
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.5,
                                    ),
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

                            // Email / Password Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_isCreateMode) ...[
                                    TextFormField(
                                      key: const Key('register_name_field'),
                                      controller: _nameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      enabled: !_isLoading,
                                      textInputAction: TextInputAction.next,
                                      decoration: const InputDecoration(
                                        labelText: 'Ad Soyad',
                                        hintText: 'Adınızı ve soyadınızı girin',
                                        prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                        ),
                                      ),
                                      validator: _validateName,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  TextFormField(
                                    key: const Key('auth_email_field'),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    enabled: !_isLoading,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: l10n.email,
                                      hintText: l10n.hintEmail,
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                    ),
                                    validator: (v) => _validateEmail(v, l10n),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    key: const Key('auth_password_field'),
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    autocorrect: false,
                                    enabled: !_isLoading,
                                    textInputAction: _isCreateMode
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    onFieldSubmitted: _isCreateMode
                                        ? null
                                        : (_) => _handleEmailSubmit(),
                                    decoration: InputDecoration(
                                      labelText: l10n.password,
                                      hintText: l10n.hintPassword,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () => setState(
                                                () => _obscurePassword =
                                                    !_obscurePassword,
                                              ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (v) =>
                                        _validatePassword(v, l10n),
                                  ),

                                  // Forgot Password link in Login mode
                                  if (!_isCreateMode)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        key: const Key(
                                          'forgot_password_button',
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () =>
                                                  ForgotPasswordScreen.showSheet(
                                                    context,
                                                    initialEmail:
                                                        _emailController.text,
                                                  ),
                                        child: Text(
                                          l10n.forgotPasswordQuestion,
                                          style: AppTypography.label(
                                            fontSize: 12.5,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Confirm Password & Terms in Register mode
                                  if (_isCreateMode) ...[
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      key: const Key(
                                        'register_confirm_password_field',
                                      ),
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      autocorrect: false,
                                      enabled: !_isLoading,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) =>
                                          _handleEmailSubmit(),
                                      decoration: InputDecoration(
                                        labelText: l10n.confirmPasswordLabel,
                                        hintText: l10n.confirmPasswordHint,
                                        prefixIcon: const Icon(
                                          Icons.lock_reset_rounded,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => setState(
                                                  () => _obscureConfirmPassword =
                                                      !_obscureConfirmPassword,
                                                ),
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                        ),
                                      ),
                                      validator: _validateConfirmPassword,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          key: const Key(
                                            'register_terms_checkbox',
                                          ),
                                          value: _acceptedTerms,
                                          activeColor: AppColors.primary,
                                          checkColor: AppColors.primaryText,
                                          onChanged: _isLoading
                                              ? null
                                              : (val) => setState(() {
                                                  _acceptedTerms = val ?? false;
                                                  if (_acceptedTerms) {
                                                    _errorMessage = null;
                                                  }
                                                }),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: _showTermsDialog,
                                            child: Text.rich(
                                              TextSpan(
                                                text: l10n.termsAcceptPrefix,
                                                style: AppTypography.description(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppColors.muted
                                                      : AppColors
                                                            .lightTextSecondary,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: l10n.termsAcceptLink,
                                                    style: AppTypography.label(
                                                      fontSize: 12,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: l10n.termsAcceptSuffix,
                                                    style: AppTypography.description(
                                                      fontSize: 12,
                                                      color: isDark
                                                          ? AppColors.muted
                                                          : AppColors
                                                                .lightTextSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ] else
                                    const SizedBox(height: 6),

                                  ArenaButton(
                                    key: const Key('auth_submit_button'),
                                    label: _isCreateMode
                                        ? l10n.createAccount
                                        : l10n.login,
                                    icon: _isCreateMode
                                        ? Icons.person_add_alt_1_rounded
                                        : Icons.login_rounded,
                                    isLoading: _isLoading,
                                    expand: true,
                                    onTap: _handleEmailSubmit,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 3. Social & Guest Sign-In Options
                    StaggeredEntrance(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.lightBorder,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Text(
                                  l10n.or.toUpperCase(),
                                  style: AppTypography.label(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.lightBorder,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Google Sign-In Button
                          _SocialAuthButton(
                            key: const Key('google_sign_in_button'),
                            label: l10n.googleLogin,
                            leading: const _GoogleGIcon(),
                            onTap: _isLoading ? null : _handleSignInWithGoogle,
                          ),
                          const SizedBox(height: 10),

                          // Apple & Guest Row
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: l10n.appleLogin,
                                  icon: Icons.apple,
                                  expand: true,
                                  onTap: _isLoading
                                      ? null
                                      : _handleSignInWithApple,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SecondaryButton(
                                  key: const Key('guest_sign_in_button'),
                                  label: l10n.guestLogin,
                                  icon: Icons.play_arrow_rounded,
                                  iconColor: AppColors.primary,
                                  expand: true,
                                  onTap: _isLoading
                                      ? null
                                      : _handleSignInAnonymously,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeroHeader extends StatelessWidget {
  final bool isDark;

  const _AuthHeroHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.heroPitchGradient : null,
        color: isDark ? null : AppColors.lightSurface,
        borderRadius: AppRadius.heroBorder,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppShadows.card : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              MiniSosGridGraphic(size: 52),
              SizedBox(width: 14),
              GoalverseEmblem(size: 58),
              SizedBox(width: 14),
              FutMiniCardGraphic(size: 52),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppConstants.appBrandUpper,
            textAlign: TextAlign.center,
            style: AppTypography.heroDisplay(
              fontSize: 32,
              color: isDark ? AppColors.foreground : AppColors.lightTextPrimary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppConstants.appSubtitleTr} • ELO puanını ve kariyer istatistiklerini tüm cihazlarında koru.',
            textAlign: TextAlign.center,
            style: AppTypography.description(
              fontSize: 12.5,
              color: isDark ? AppColors.muted : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.button(
            fontSize: 13.5,
            color: selected
                ? AppColors.primaryText
                : (isDark ? AppColors.muted : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final VoidCallback? onTap;

  const _SocialAuthButton({
    super.key,
    required this.label,
    required this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.button(
                fontSize: 14.5,
                color: isDark
                    ? AppColors.foreground
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: AppTypography.statValue(
          fontSize: 14,
          color: const Color(0xFF4285F4),
        ),
      ),
    );
  }
}
