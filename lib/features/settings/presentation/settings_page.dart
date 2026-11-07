import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/monetization/monetization_l10n.dart';
import '../../../core/monetization/premium_service.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/auth_error_mapper.dart';
import '../../auth/presentation/forgot_password_screen.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _supportedLanguages = <(String?, String, String)>[
    (null, '🌐', 'System'),
    ('en', '🇬🇧', 'English'),
    ('tr', '🇹🇷', 'Türkçe'),
    ('de', '🇩🇪', 'Deutsch'),
    ('es', '🇪🇸', 'Español'),
    ('fr', '🇫🇷', 'Français'),
    ('it', '🇮🇹', 'Italiano'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mL10n = MonetizationL10n.of(context);
    final isPro = ref.watch(isPremiumActiveProvider);
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Appearance / Theme Section
                _SectionHeader(title: l10n.theme, icon: Icons.palette_outlined),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_outlined),
                          label: Text(l10n.systemMode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_outlined),
                          label: Text(l10n.lightMode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_outlined),
                          label: Text(l10n.darkMode),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (newSelection) {
                        settingsNotifier.setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Language Section
                _SectionHeader(
                  title: l10n.language,
                  icon: Icons.language_outlined,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _supportedLanguages.map((lang) {
                        final code = lang.$1;
                        final flag = lang.$2;
                        final label = code == null ? l10n.systemMode : lang.$3;
                        final isSelected =
                            settings.locale?.languageCode == code;

                        return ChoiceChip(
                          label: Text('$flag $label'),
                          selected: isSelected,
                          onSelected: (_) {
                            settingsNotifier.setLocale(
                              code == null ? null : Locale(code),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Game Difficulty, Sound & Haptics Section
                _SectionHeader(
                  title: '${l10n.difficulty} & Kontroller',
                  icon: Icons.tune_outlined,
                ),
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.difficulty,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.trophyGold.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Süre: ${settings.turnSeconds}sn • Çarpan: ${settings.scoreMultiplier}x',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.trophyGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment(
                                  value: 'easy',
                                  label: Text(l10n.easy),
                                  icon: const Icon(
                                    Icons.sentiment_satisfied_alt,
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'medium',
                                  label: Text(l10n.medium),
                                  icon: const Icon(Icons.sports_soccer),
                                ),
                                ButtonSegment(
                                  value: 'hard',
                                  label: Text(l10n.hard),
                                  icon: const Icon(Icons.local_fire_department),
                                ),
                              ],
                              selected: {settings.difficulty},
                              onSelectionChanged: (selected) {
                                settingsNotifier.setDifficulty(selected.first);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.vibration_rounded),
                        title: const Text('Titreşim (Haptic Geri Bildirim)'),
                        subtitle: const Text(
                          'Doğru ve yanlış tahminlerde dokunsal geri bildirim',
                        ),
                        value: settings.hapticsEnabled,
                        onChanged: (val) =>
                            settingsNotifier.setHapticsEnabled(val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_up_outlined),
                        title: const Text('Ses Efektleri'),
                        subtitle: const Text(
                          'Stadyum ve maç içi ses efektleri',
                        ),
                        value: settings.soundEnabled,
                        onChanged: (val) =>
                            settingsNotifier.setSoundEnabled(val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_outlined),
                        title: Text(l10n.notifications),
                        subtitle: Text(
                          settings.notificationsEnabled
                              ? l10n.notificationsEnabled
                              : l10n.notificationsDisabled,
                        ),
                        value: settings.notificationsEnabled,
                        onChanged: (val) =>
                            settingsNotifier.setNotificationsEnabled(val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Football SOS Pro & Cosmetic Store Section
                _SectionHeader(
                  title: mL10n.tr('pro_title'),
                  icon: Icons.workspace_premium_rounded,
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppTheme.trophyGold,
                        ),
                        title: Text(mL10n.tr('pro_title')),
                        subtitle: Text(
                          isPro
                              ? mL10n.tr('pro_active_badge')
                              : mL10n.tr('pro_subtitle'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/premium'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.storefront_rounded,
                          color: AppTheme.primary,
                        ),
                        title: Text(mL10n.tr('store_title')),
                        subtitle: Text(
                          mL10n.tr('store_subtitle'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/store'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.restore_rounded),
                        title: Text(mL10n.tr('restore_purchases')),
                        onTap: () async {
                          final ok = await ref
                              .read(purchaseServiceProvider.notifier)
                              .restorePurchases();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                mL10n.tr(
                                  ok ? 'restore_success' : 'restore_empty',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Account Section
                _SectionHeader(
                  title: l10n.profile,
                  icon: Icons.manage_accounts_outlined,
                ),
                Card(
                  child: Column(
                    children: [
                      if (user != null && user.isAnonymous)
                        ListTile(
                          leading: const Icon(
                            Icons.link,
                            color: AppTheme.trophyGold,
                          ),
                          title: Text(l10n.linkAccount),
                          subtitle: Text(l10n.linkAccountSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/link-account'),
                        ),
                      if (user != null &&
                          !user.isAnonymous &&
                          user.providerId == 'password') ...[
                        ListTile(
                          leading: const Icon(
                            Icons.lock_reset_rounded,
                            color: AppTheme.primary,
                          ),
                          title: const Text(
                            'Şifre Sıfırlama Bağlantısı Gönder',
                          ),
                          subtitle: Text(user.email ?? ''),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => ForgotPasswordScreen.showSheet(
                            context,
                            initialEmail: user.email ?? '',
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                      ListTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: AppTheme.warning,
                        ),
                        title: Text(
                          l10n.logout,
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onTap: () async {
                          await authRepo.signOut();
                          if (context.mounted) {
                            context.go('/auth');
                          }
                        },
                      ),
                      if (user != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever_rounded,
                            color: AppTheme.crimsonStrike,
                          ),
                          title: const Text(
                            'Hesabı Kalıcı Olarak Sil',
                            style: TextStyle(
                              color: AppTheme.crimsonStrike,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: const Text(
                            'Profil verilerinizi ve hesabınızı kalıcı olarak siler',
                          ),
                          onTap: () => _showDeleteAccountDialog(
                            context,
                            ref,
                            requirePassword:
                                !user.isAnonymous &&
                                user.providerId == 'password',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // About & Support Section
                _SectionHeader(title: l10n.about, icon: Icons.info_outline),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.sports_soccer_rounded),
                        title: const Text('Marka'),
                        trailing: const Text(
                          AppConstants.appBrandUpper,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.verified_outlined),
                        title: Text(l10n.version),
                        trailing: Text(
                          '2.0.0+${AppConstants.datasetVersion}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(l10n.help),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showInfoDialog(
                          context,
                          l10n.help,
                          '${AppConstants.appName} • 7 Oyun Modu (Single & Multiplayer):\n\n'
                          '• Football SOS (3x3 Grid: vs Akıllı Bot, 2P Düello & Online)\n'
                          '• Rating Battle (1P Seri & 2P Düello)\n'
                          '• 2 Takım 1 Oyuncu (1P & 2P Düello)\n'
                          '• Ben Kimim? (1P & 2P Düello)\n'
                          '• Imposter • Ajan Kim? (1P & 2P Düello)\n'
                          '• Transfer Path • Kariyer Yolu (1P & 2P Düello)\n'
                          '• Football Bomb 💣 (1-8 Kişilik Parti Modu)',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool requirePassword,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final passwordCtrl = TextEditingController();
    bool isDeleting = false;
    String? errorMsg;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Hesabı Kalıcı Olarak Sil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bu işlem geri alınamaz. ELO puanınız, galibiyet geçmişiniz ve kullanıcı profiliniz kalıcı olarak silinecektir.',
              ),
              if (requirePassword) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    hintText: 'Onay için mevcut şifrenizi girin',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMsg!,
                  style: const TextStyle(
                    color: AppTheme.crimsonStrike,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.crimsonStrike,
                foregroundColor: Colors.white,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      if (requirePassword && passwordCtrl.text.trim().isEmpty) {
                        setDialogState(
                          () => errorMsg = 'Lütfen mevcut şifrenizi girin.',
                        );
                        return;
                      }
                      setDialogState(() {
                        isDeleting = true;
                        errorMsg = null;
                      });
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .deleteAccount(
                              currentPassword: requirePassword
                                  ? passwordCtrl.text
                                  : null,
                            );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) context.go('/auth');
                      } catch (e) {
                        if (!ctx.mounted) return;
                        setDialogState(() {
                          isDeleting = false;
                          errorMsg = AuthErrorMapper.mapException(e, l10n);
                        });
                      }
                    },
              child: Text(isDeleting ? 'Siliniyor...' : 'Hesabı Sil'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
