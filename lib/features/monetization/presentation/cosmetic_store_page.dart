import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monetization/ad_service.dart';
import '../../../core/monetization/cosmetic_store_service.dart';
import '../../../core/monetization/monetization_l10n.dart';
import '../../../core/monetization/monetization_models.dart';
import '../../../core/monetization/premium_service.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../l10n/app_localizations.dart';

class CosmeticStorePage extends ConsumerStatefulWidget {
  const CosmeticStorePage({super.key});

  @override
  ConsumerState<CosmeticStorePage> createState() => _CosmeticStorePageState();
}

class _CosmeticStorePageState extends ConsumerState<CosmeticStorePage> {
  CosmeticCategory? _selectedCategory;

  String _categoryLabel(MonetizationL10n mL10n, CosmeticCategory cat) {
    return switch (cat) {
      CosmeticCategory.pitchTheme => mL10n.tr('cat_pitch_theme'),
      CosmeticCategory.boardTheme => mL10n.tr('cat_board_theme'),
      CosmeticCategory.profileFrame => mL10n.tr('cat_profile_frame'),
      CosmeticCategory.avatar => mL10n.tr('cat_avatar'),
      CosmeticCategory.badge => mL10n.tr('cat_badge'),
      CosmeticCategory.seasonal => mL10n.tr('cat_seasonal'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final mL10n = MonetizationL10n.of(context);
    final isPro = ref.watch(isPremiumActiveProvider);
    final storeState = ref.watch(cosmeticStoreServiceProvider);
    final storeNotifier = ref.read(cosmeticStoreServiceProvider.notifier);
    final purchaseState = ref.watch(purchaseServiceProvider);
    final purchaseNotifier = ref.read(purchaseServiceProvider.notifier);
    final adService = ref.read(adServiceProvider.notifier);
    final adState = ref.watch(adServiceProvider);
    final catalog = ref.watch(activeCosmeticCatalogProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = _selectedCategory == null
        ? catalog
        : catalog.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(mL10n.tr('store_title')),
        actions: [
          TextButton.icon(
            key: const Key('store_restore_purchases_button'),
            onPressed: purchaseState.isProcessingPurchase
                ? null
                : () async {
                    final restored = await purchaseNotifier.restorePurchases();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          mL10n.tr(
                            restored ? 'restore_success' : 'restore_empty',
                          ),
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: Text(
              mL10n.tr('restore_purchases'),
              style: AppTypography.label(
                fontSize: 11.5,
                color: AppColors.electricLime,
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
              constraints: const BoxConstraints(maxWidth: 920),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Football SOS Pro Banner / Upsell Card
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/premium'),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroPitchGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.trophyGold.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF101B18),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPro
                                        ? mL10n.tr('pro_active_badge')
                                        : mL10n.tr('pro_title'),
                                    style: AppTypography.titleMedium(
                                      fontSize: 16,
                                      color: AppColors.trophyGold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    mL10n.tr('store_subtitle'),
                                    style: AppTypography.description(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.trophyGold,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 2. Category Filter Chips (All + 6 Categories)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(AppLocalizations.of(context)?.filterAll ?? 'Tümü'),
                              selected: _selectedCategory == null,
                              onSelected: (_) {
                                setState(() => _selectedCategory = null);
                              },
                            ),
                          ),
                          for (final cat in CosmeticCategory.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                key: Key('store_cat_${cat.wireKey}'),
                                label: Text(_categoryLabel(mL10n, cat)),
                                selected: _selectedCategory == cat,
                                onSelected: (_) {
                                  setState(() => _selectedCategory = cat);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3. Cosmetic Items Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 720
                            ? 3
                            : constraints.maxWidth >= 480
                            ? 2
                            : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                mainAxisExtent: 255,
                              ),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final permanentlyOwned = storeState
                                .purchasedProductIds
                                .contains(item.productId);
                            final unlocked =
                                permanentlyOwned ||
                                (item.includedWithPro && isPro);
                            final equipped =
                                storeState.equipped.equippedForCategory(
                                  item.category,
                                ) ==
                                item.id;
                            final quote = purchaseState.quoteFor(
                              item.productId,
                            );
                            final adProgress =
                                storeState.rewardedProgressByProductId[item
                                    .productId] ??
                                0;
                            final adTarget = item.rewardedAdsRequired ?? 3;

                            return _CosmeticItemCard(
                              key: Key('cosmetic_card_${item.productId}'),
                              item: item,
                              categoryName: _categoryLabel(
                                mL10n,
                                item.category,
                              ),
                              title: mL10n.tr(item.titleKey),
                              subtitle: mL10n.tr(item.subtitleKey),
                              permanentlyOwned: permanentlyOwned,
                              unlocked: unlocked,
                              equipped: equipped,
                              priceText: quote?.formattedPrice ?? '...',
                              adProgress: adProgress,
                              adTarget: adTarget,
                              isBusy:
                                  purchaseState.isProcessingPurchase ||
                                  adState.isShowingRewardedAd,
                              mL10n: mL10n,
                              onEquip: () async {
                                await storeNotifier.equipItem(
                                  item,
                                  isProActive: isPro,
                                );
                              },
                              onBuy: () async {
                                final res = await purchaseNotifier
                                    .purchaseCosmetic(item);
                                if (!context.mounted) return;
                                final msgKey =
                                    res.messageKey ?? 'purchase_failed';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(mL10n.tr(msgKey))),
                                );
                              },
                              onWatchAd: () async {
                                final res = await adService
                                    .watchRewardedAdForCosmetic(item);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      mL10n.tr(
                                        res.rewardEarned
                                            ? 'rewarded_ad_completed'
                                            : 'rewarded_ad_incomplete',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
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

class _CosmeticItemCard extends StatelessWidget {
  final CosmeticItem item;
  final String categoryName;
  final String title;
  final String subtitle;
  final bool permanentlyOwned;
  final bool unlocked;
  final bool equipped;
  final String priceText;
  final int adProgress;
  final int adTarget;
  final bool isBusy;
  final MonetizationL10n mL10n;
  final VoidCallback onEquip;
  final VoidCallback onBuy;
  final VoidCallback onWatchAd;

  const _CosmeticItemCard({
    super.key,
    required this.item,
    required this.categoryName,
    required this.title,
    required this.subtitle,
    required this.permanentlyOwned,
    required this.unlocked,
    required this.equipped,
    required this.priceText,
    required this.adProgress,
    required this.adTarget,
    required this.isBusy,
    required this.mL10n,
    required this.onEquip,
    required this.onBuy,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPreview = item.previewColors.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: equipped
              ? AppColors.electricLime
              : unlocked
              ? AppColors.trophyGold.withValues(alpha: 0.55)
              : (isDark ? AppColors.border : AppColors.lightBorder),
          width: equipped ? 2.0 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Preview Row + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.previewColors.length >= 2
                        ? item.previewColors.take(2).toList()
                        : [primaryPreview, AppColors.surfaceElevated],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(item.icon, color: Colors.white, size: 22),
              ),
              if (equipped)
                _StatusBadge(
                  text: mL10n.tr('equipped_badge'),
                  color: AppColors.electricLime,
                )
              else if (permanentlyOwned)
                _StatusBadge(
                  text: mL10n.tr('owned_badge'),
                  color: AppColors.skyBlue,
                )
              else if (item.includedWithPro)
                _StatusBadge(
                  text: mL10n.tr('included_with_pro'),
                  color: AppColors.trophyGold,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            categoryName.toUpperCase(),
            style: AppTypography.label(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium(
              fontSize: 15,
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.description(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Action Row: Equip if unlocked, otherwise Buy or Watch Rewarded Ad
          if (unlocked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: Key('equip_button_${item.productId}'),
                onPressed: equipped ? null : onEquip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: equipped
                      ? AppColors.surfaceElevated
                      : AppColors.electricLime,
                  foregroundColor: const Color(0xFF101B18),
                ),
                icon: Icon(
                  equipped ? Icons.check_rounded : Icons.check_circle_outline,
                  size: 16,
                ),
                label: Text(
                  equipped
                      ? mL10n.tr('equipped_badge')
                      : mL10n.tr('equip_button'),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    key: Key('buy_button_${item.productId}'),
                    onPressed: isBusy ? null : onBuy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricLime,
                      foregroundColor: const Color(0xFF101B18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      mL10n.tr('buy_cosmetic_button', {'price': priceText}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        fontSize: 11.5,
                        color: const Color(0xFF101B18),
                      ),
                    ),
                  ),
                ),
                if (item.rewardedAdsRequired != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    key: Key('watch_ad_button_${item.productId}'),
                    onPressed: isBusy ? null : onWatchAd,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.trophyGold,
                      side: BorderSide(
                        color: AppColors.trophyGold.withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 16,
                    ),
                    label: Text(
                      '$adProgress/$adTarget',
                      style: AppTypography.numericMedium(
                        fontSize: 11.5,
                        color: AppColors.trophyGold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadius.pillBorder,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: AppTypography.label(fontSize: 10, color: color)),
    );
  }
}
