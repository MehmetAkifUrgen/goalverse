import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monetization/monetization_l10n.dart';
import '../../../core/monetization/monetization_models.dart';
import '../../../core/monetization/premium_service.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/monetization/remote_config_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';

class PremiumPaywallPage extends ConsumerStatefulWidget {
  const PremiumPaywallPage({super.key});

  @override
  ConsumerState<PremiumPaywallPage> createState() => _PremiumPaywallPageState();
}

class _PremiumPaywallPageState extends ConsumerState<PremiumPaywallPage> {
  String _selectedProductId = MonetizationProductIds.proYearly;

  IconData _benefitIcon(String key) {
    return switch (key) {
      'pro_benefit_no_ads' => Icons.block_rounded,
      'pro_benefit_frames' => Icons.crop_original_rounded,
      'pro_benefit_badge' => Icons.workspace_premium_rounded,
      'pro_benefit_board_themes' => Icons.grid_4x4_rounded,
      'pro_benefit_detailed_stats' => Icons.analytics_outlined,
      'pro_benefit_extended_history' => Icons.history_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  String _statusLabel(MonetizationL10n mL10n, SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.active => mL10n.tr('status_active'),
      SubscriptionStatus.activeUntilExpiry => mL10n.tr(
        'status_active_until_expiry',
      ),
      SubscriptionStatus.gracePeriod => mL10n.tr('status_grace_period'),
      SubscriptionStatus.billingRetry => mL10n.tr('status_billing_retry'),
      SubscriptionStatus.expired => mL10n.tr('status_expired'),
      _ => mL10n.tr('status_none'),
    };
  }

  void _showManageSubscriptionDialog(
    BuildContext context,
    MonetizationL10n mL10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(mL10n.tr('manage_subscription')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aboneliğinizi Google Play veya App Store hesap ayarlarınız üzerinden istediğiniz zaman yönetebilir veya iptal edebilirsiniz. İptal edilen abonelikler dönem sonuna kadar aktif kalır.',
            ),
            const SizedBox(height: 14),
            SelectableText(
              'Google Play: ${RevenueCatConfig.playStoreSubscriptionsUrl}\nApp Store: ${RevenueCatConfig.appStoreSubscriptionsUrl}',
              style: AppTypography.label(
                fontSize: 11.5,
                color: AppColors.skyBlue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(
                  text: RevenueCatConfig.playStoreSubscriptionsUrl,
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Bağlantıyı Kopyala'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineLarge(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: AppTypography.description(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mL10n = MonetizationL10n.of(context);
    final entitlement = ref.watch(premiumServiceProvider);
    final isPro = ref.watch(isPremiumActiveProvider);
    final purchaseState = ref.watch(purchaseServiceProvider);
    final purchaseNotifier = ref.read(purchaseServiceProvider.notifier);
    final remoteConfig = ref.watch(monetizationRemoteConfigProvider);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final effectiveStatus = entitlement.effectiveStatusAt(nowMs);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final monthlyQuote = purchaseState.quoteFor(
      MonetizationProductIds.proMonthly,
    );
    final yearlyQuote = purchaseState.quoteFor(
      MonetizationProductIds.proYearly,
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(mL10n.tr('pro_title')),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/store'),
            icon: const Icon(
              Icons.storefront_rounded,
              size: 18,
              color: AppColors.trophyGold,
            ),
            label: Text(
              mL10n.tr('store_title'),
              style: AppTypography.label(
                fontSize: 12,
                color: AppColors.trophyGold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StadiumPitchBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Hero Football SOS Pro Header Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPitchGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.trophyGold.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                        boxShadow: AppShadows.hero,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  borderRadius: AppRadius.pillBorder,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 16,
                                      color: Color(0xFF101B18),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isPro
                                          ? mL10n.tr('pro_active_badge')
                                          : 'FOOTBALL SOS PRO',
                                      style: AppTypography.label(
                                        fontSize: 11,
                                        color: const Color(0xFF101B18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPro
                                      ? AppColors.electricLime.withValues(
                                          alpha: 0.16,
                                        )
                                      : AppColors.surfaceElevated,
                                  borderRadius: AppRadius.pillBorder,
                                  border: Border.all(
                                    color: isPro
                                        ? AppColors.electricLime
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  _statusLabel(mL10n, effectiveStatus),
                                  style: AppTypography.label(
                                    fontSize: 10.5,
                                    color: isPro
                                        ? AppColors.electricLime
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            mL10n.tr('pro_title'),
                            style: AppTypography.displayLarge(
                              fontSize: 28,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mL10n.tr('pro_subtitle'),
                            style: AppTypography.description(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Fair Play Guarantee Banner (Zero Competitive Advantage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.electricLime.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.electricLime,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mL10n.tr('pro_fair_play_notice'),
                              style: AppTypography.description(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Premium Benefits List (Driven by Remote Config)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.border
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (
                            var i = 0;
                            i < remoteConfig.premiumFeatureKeys.length;
                            i++
                          ) ...[
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.electricLime.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _benefitIcon(
                                      remoteConfig.premiumFeatureKeys[i],
                                    ),
                                    size: 18,
                                    color: AppColors.electricLime,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    mL10n.tr(
                                      remoteConfig.premiumFeatureKeys[i],
                                    ),
                                    style: AppTypography.titleMedium(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.textPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: AppColors.electricLime,
                                ),
                              ],
                            ),
                            if (i < remoteConfig.premiumFeatureKeys.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1),
                              ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 4. Plan Selector Cards (Monthly & Yearly with Dynamic Store Prices)
                    _SubscriptionPlanCard(
                      key: const Key('plan_card_yearly'),
                      productId: MonetizationProductIds.proYearly,
                      title: mL10n.tr('plan_yearly_title'),
                      subtitle: mL10n.tr('plan_yearly_subtitle'),
                      priceLabel: purchaseState.isLoadingQuotes
                          ? mL10n.tr('price_loading')
                          : (yearlyQuote?.formattedPrice ??
                                mL10n.tr('price_unavailable')),
                      badgeText:
                          yearlyQuote?.introductoryPrice ??
                          mL10n.tr('plan_best_value'),
                      selected:
                          _selectedProductId ==
                          MonetizationProductIds.proYearly,
                      isCurrentPlan:
                          isPro &&
                          entitlement.subscriptionProductId ==
                              MonetizationProductIds.proYearly,
                      onTap: () {
                        setState(() {
                          _selectedProductId = MonetizationProductIds.proYearly;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _SubscriptionPlanCard(
                      key: const Key('plan_card_monthly'),
                      productId: MonetizationProductIds.proMonthly,
                      title: mL10n.tr('plan_monthly_title'),
                      subtitle: mL10n.tr('plan_monthly_subtitle'),
                      priceLabel: purchaseState.isLoadingQuotes
                          ? mL10n.tr('price_loading')
                          : (monthlyQuote?.formattedPrice ??
                                mL10n.tr('price_unavailable')),
                      selected:
                          _selectedProductId ==
                          MonetizationProductIds.proMonthly,
                      isCurrentPlan:
                          isPro &&
                          entitlement.subscriptionProductId ==
                              MonetizationProductIds.proMonthly,
                      onTap: () {
                        setState(() {
                          _selectedProductId =
                              MonetizationProductIds.proMonthly;
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    // 5. Primary Purchase CTA Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        key: const Key('buy_football_sos_pro_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricLime,
                          foregroundColor: const Color(0xFF101B18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: purchaseState.isProcessingPurchase
                            ? null
                            : () async {
                                final res = await purchaseNotifier
                                    .purchaseSubscription(_selectedProductId);
                                if (!context.mounted) return;
                                final msgKey =
                                    res.messageKey ?? 'purchase_failed';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(mL10n.tr(msgKey))),
                                );
                              },
                        icon: purchaseState.isProcessingPurchase
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.workspace_premium_rounded),
                        label: Text(
                          mL10n.tr('buy_pro_button'),
                          style: AppTypography.titleMedium(
                            fontSize: 16,
                            color: const Color(0xFF101B18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 6. Restore Purchases, Manage Subscription, Terms & Privacy Links
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        TextButton.icon(
                          key: const Key('restore_purchases_button'),
                          onPressed: purchaseState.isProcessingPurchase
                              ? null
                              : () async {
                                  final restored = await purchaseNotifier
                                      .restorePurchases();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        mL10n.tr(
                                          restored
                                              ? 'restore_success'
                                              : 'restore_empty',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.restore_rounded, size: 16),
                          label: Text(mL10n.tr('restore_purchases')),
                        ),
                        TextButton.icon(
                          key: const Key('manage_subscription_button'),
                          onPressed: () =>
                              _showManageSubscriptionDialog(context, mL10n),
                          icon: const Icon(
                            Icons.subscriptions_outlined,
                            size: 16,
                          ),
                          label: Text(mL10n.tr('manage_subscription')),
                        ),
                        TextButton(
                          key: const Key('terms_of_use_button'),
                          onPressed: () => _showLegalSheet(
                            context,
                            title: mL10n.tr('terms_of_use'),
                            body:
                                'Football SOS Pro abonelikleri Google Play veya App Store hesabınız üzerinden faturalandırılır. Cari dönem bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Abonelik iptal edildiğinde mevcut fatura dönemi sonuna kadar Football SOS Pro haklarınız aktif kalır.',
                          ),
                          child: Text(mL10n.tr('terms_of_use')),
                        ),
                        TextButton(
                          key: const Key('privacy_policy_button'),
                          onPressed: () => _showLegalSheet(
                            context,
                            title: mL10n.tr('privacy_policy'),
                            body:
                                'Satın alma ve abonelik doğrulamaları Firebase Authentication UID\'niz ve RevenueCat / resmi uygulama mağazası makbuz doğrulama altyapısı ile güvenli şekilde işlenir. Ödeme kartı bilgileriniz hiçbir zaman uygulama sunucularımızda saklanmaz.',
                          ),
                          child: Text(mL10n.tr('privacy_policy')),
                        ),
                      ],
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

class _SubscriptionPlanCard extends StatelessWidget {
  final String productId;
  final String title;
  final String subtitle;
  final String priceLabel;
  final String? badgeText;
  final bool selected;
  final bool isCurrentPlan;
  final VoidCallback onTap;

  const _SubscriptionPlanCard({
    super.key,
    required this.productId,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    this.badgeText,
    required this.selected,
    this.isCurrentPlan = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? AppColors.electricLime
        : (isDark ? AppColors.border : AppColors.lightBorder);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surfaceElevated
              : (isDark ? AppColors.surface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 2.0 : 1.0),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.electricLime : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.titleMedium(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.trophyGold.withValues(alpha: 0.2),
                            borderRadius: AppRadius.pillBorder,
                            border: Border.all(color: AppColors.trophyGold),
                          ),
                          child: Text(
                            badgeText!,
                            style: AppTypography.label(
                              fontSize: 10,
                              color: AppColors.trophyGold,
                            ),
                          ),
                        ),
                      ],
                      if (isCurrentPlan) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricLime.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: AppRadius.pillBorder,
                          ),
                          child: Text(
                            'AKTİF',
                            style: AppTypography.label(
                              fontSize: 10,
                              color: AppColors.electricLime,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.description(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              priceLabel,
              style: AppTypography.numericMedium(
                fontSize: 15,
                color: selected
                    ? AppColors.electricLime
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
