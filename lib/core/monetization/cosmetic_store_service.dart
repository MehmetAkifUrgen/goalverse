import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import 'monetization_models.dart';
import 'remote_config_service.dart';

class CosmeticStoreState {
  final Set<String> purchasedProductIds;
  final Map<String, int> rewardedProgressByProductId;
  final EquippedCosmetics equipped;
  final bool isLoading;

  const CosmeticStoreState({
    this.purchasedProductIds = const <String>{},
    this.rewardedProgressByProductId = const <String, int>{},
    this.equipped = const EquippedCosmetics(),
    this.isLoading = false,
  });

  CosmeticStoreState copyWith({
    Set<String>? purchasedProductIds,
    Map<String, int>? rewardedProgressByProductId,
    EquippedCosmetics? equipped,
    bool? isLoading,
  }) {
    return CosmeticStoreState(
      purchasedProductIds: purchasedProductIds ?? this.purchasedProductIds,
      rewardedProgressByProductId:
          rewardedProgressByProductId ?? this.rewardedProgressByProductId,
      equipped: equipped ?? this.equipped,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Manages the Football SOS Cosmetic Store, permanent account-bound cosmetic
/// ownership, Pro-included cosmetics, rewarded-ad unlock progress, and equipped themes.
class CosmeticStoreService extends StateNotifier<CosmeticStoreState> {
  static const String _cacheKeyPrefix = 'cosmetic_store_state_v1';

  final String? _uid;
  final FirebaseFirestore? _firestore;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  CosmeticStoreService({
    required String? uid,
    FirebaseFirestore? firestore,
    CosmeticStoreState? initialState,
  }) : _uid = uid,
       _firestore = firestore,
       super(initialState ?? const CosmeticStoreState()) {
    _initialize();
  }

  static const List<CosmeticItem> catalog = <CosmeticItem>[
    // 1. Saha Temaları (Pitch Themes)
    CosmeticItem(
      id: 'pitch_champions_night',
      productId: MonetizationProductIds.pitchChampionsNight,
      category: CosmeticCategory.pitchTheme,
      titleKey: 'item_pitch_champions_title',
      subtitleKey: 'item_pitch_champions_desc',
      previewColors: <Color>[
        Color(0xFF0E2F23),
        Color(0xFF1E6B47),
        Color(0xFFC6F36B),
      ],
      icon: Icons.stadium_rounded,
      includedWithPro: true,
      rewardedAdsRequired: 3,
    ),
    CosmeticItem(
      id: 'pitch_golden_arena',
      productId: MonetizationProductIds.pitchGoldenArena,
      category: CosmeticCategory.pitchTheme,
      titleKey: 'item_pitch_golden_title',
      subtitleKey: 'item_pitch_golden_desc',
      previewColors: <Color>[
        Color(0xFF1F271B),
        Color(0xFF3E4E2C),
        Color(0xFFF3C969),
      ],
      icon: Icons.emoji_events_rounded,
      includedWithPro: false,
      rewardedAdsRequired: 5,
    ),

    // 2. Oyun Tahtası Temaları (Board Themes)
    CosmeticItem(
      id: 'board_neon_tactical',
      productId: MonetizationProductIds.boardNeonTactical,
      category: CosmeticCategory.boardTheme,
      titleKey: 'item_board_neon_title',
      subtitleKey: 'item_board_neon_desc',
      previewColors: <Color>[
        Color(0xFF173D2B),
        Color(0xFFC6F36B),
        Color(0xFF72B7E8),
      ],
      icon: Icons.grid_4x4_rounded,
      includedWithPro: true,
      rewardedAdsRequired: 3,
    ),
    CosmeticItem(
      id: 'board_royal_gold',
      productId: MonetizationProductIds.boardRoyalGold,
      category: CosmeticCategory.boardTheme,
      titleKey: 'item_board_royal_title',
      subtitleKey: 'item_board_royal_desc',
      previewColors: <Color>[
        Color(0xFF231F18),
        Color(0xFFF3C969),
        Color(0xFFE5A93B),
      ],
      icon: Icons.grid_view_rounded,
      includedWithPro: false,
      rewardedAdsRequired: 4,
    ),

    // 3. Profil Çerçeveleri (Profile Frames)
    CosmeticItem(
      id: 'frame_ballon_dor',
      productId: MonetizationProductIds.frameBallonDor,
      category: CosmeticCategory.profileFrame,
      titleKey: 'item_frame_ballon_title',
      subtitleKey: 'item_frame_ballon_desc',
      previewColors: <Color>[
        Color(0xFFF3C969),
        Color(0xFFD99B26),
        Color(0xFFFFF3C4),
      ],
      icon: Icons.workspace_premium_rounded,
      includedWithPro: true,
      rewardedAdsRequired: 3,
    ),
    CosmeticItem(
      id: 'frame_emerald_captain',
      productId: MonetizationProductIds.frameEmeraldCaptain,
      category: CosmeticCategory.profileFrame,
      titleKey: 'item_frame_emerald_title',
      subtitleKey: 'item_frame_emerald_desc',
      previewColors: <Color>[
        Color(0xFF2D754B),
        Color(0xFFC6F36B),
        Color(0xFF72B7E8),
      ],
      icon: Icons.verified_user_rounded,
      includedWithPro: false,
      rewardedAdsRequired: 3,
    ),

    // 4. Avatarlar (Avatars)
    CosmeticItem(
      id: 'avatar_striker_9',
      productId: MonetizationProductIds.avatarStriker9,
      category: CosmeticCategory.avatar,
      titleKey: 'item_avatar_striker_title',
      subtitleKey: 'item_avatar_striker_desc',
      previewColors: <Color>[
        Color(0xFFF07870),
        Color(0xFF20543A),
        Color(0xFFF3C969),
      ],
      icon: Icons.sports_soccer_rounded,
      includedWithPro: false,
      rewardedAdsRequired: 3,
    ),
    CosmeticItem(
      id: 'avatar_maestro_10',
      productId: MonetizationProductIds.avatarMaestro10,
      category: CosmeticCategory.avatar,
      titleKey: 'item_avatar_maestro_title',
      subtitleKey: 'item_avatar_maestro_desc',
      previewColors: <Color>[
        Color(0xFF72B7E8),
        Color(0xFF173D2B),
        Color(0xFFC6F36B),
      ],
      icon: Icons.auto_awesome_rounded,
      includedWithPro: true,
      rewardedAdsRequired: 3,
    ),

    // 5. Özel Rozetler (Custom Badges)
    CosmeticItem(
      id: 'badge_tactical_genius',
      productId: MonetizationProductIds.badgeTacticalGenius,
      category: CosmeticCategory.badge,
      titleKey: 'item_badge_tactical_title',
      subtitleKey: 'item_badge_tactical_desc',
      previewColors: <Color>[
        Color(0xFFC6F36B),
        Color(0xFF20543A),
        Color(0xFF72B7E8),
      ],
      icon: Icons.psychology_rounded,
      includedWithPro: true,
      rewardedAdsRequired: 2,
    ),
    CosmeticItem(
      id: 'badge_unbeaten_king',
      productId: MonetizationProductIds.badgeUnbeatenKing,
      category: CosmeticCategory.badge,
      titleKey: 'item_badge_unbeaten_title',
      subtitleKey: 'item_badge_unbeaten_desc',
      previewColors: <Color>[
        Color(0xFFF3C969),
        Color(0xFFF07870),
        Color(0xFF1A2922),
      ],
      icon: Icons.military_tech_rounded,
      includedWithPro: false,
      rewardedAdsRequired: 4,
    ),

    // 6. Sezonluk Kozmetikler (Seasonal Cosmetics)
    CosmeticItem(
      id: 'season1_derby_pack',
      productId: MonetizationProductIds.season1DerbyPack,
      category: CosmeticCategory.seasonal,
      titleKey: 'item_season1_derby_title',
      subtitleKey: 'item_season1_derby_desc',
      previewColors: <Color>[
        Color(0xFFF07870),
        Color(0xFFC6F36B),
        Color(0xFF173D2B),
      ],
      icon: Icons.local_fire_department_rounded,
      includedWithPro: false,
      rewardedAdsRequired: 4,
    ),
    CosmeticItem(
      id: 'season1_trophy_aura',
      productId: MonetizationProductIds.season1TrophyAura,
      category: CosmeticCategory.seasonal,
      titleKey: 'item_season1_aura_title',
      subtitleKey: 'item_season1_aura_desc',
      previewColors: <Color>[
        Color(0xFFF3C969),
        Color(0xFFC6F36B),
        Color(0xFF20543A),
      ],
      icon: Icons.flare_rounded,
      includedWithPro: true,
      rewardedAdsRequired: 3,
    ),
  ];

  String get _scopedCacheKey => (_uid != null && _uid.isNotEmpty)
      ? '${_cacheKeyPrefix}_$_uid'
      : _cacheKeyPrefix;

  Future<void> _initialize() async {
    await _loadLocalCache();
    _subscribeToUserFirestore();
  }

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_scopedCacheKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final owned =
          (decoded['purchasedProductIds'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toSet();
      final rawProgress =
          decoded['rewardedProgressByProductId'] as Map<String, dynamic>? ??
          const {};
      final progress = rawProgress.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      );
      final equipped = EquippedCosmetics.fromMap(
        decoded['equipped'] as Map<String, dynamic>?,
      );
      state = state.copyWith(
        purchasedProductIds: owned,
        rewardedProgressByProductId: progress,
        equipped: equipped,
      );
    } catch (_) {}
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedCacheKey,
        jsonEncode({
          'purchasedProductIds': state.purchasedProductIds.toList(),
          'rewardedProgressByProductId': state.rewardedProgressByProductId,
          'equipped': state.equipped.toMap(),
        }),
      );
    } catch (_) {}
  }

  void _subscribeToUserFirestore() {
    _userSub?.cancel();
    if (_uid == null || _uid.isEmpty) return;
    final fs = _firestore ?? _tryGetDefaultFirestore();
    if (fs == null) return;

    try {
      _userSub = fs.collection('users').doc(_uid).snapshots().listen((snap) {
        final data = snap.data();
        if (data == null) return;

        final remoteOwned =
            (data['purchasedCosmeticIds'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toSet();
        final rawAdPrefs = data['adPreferences'];
        Map<String, int> remoteProgress = state.rewardedProgressByProductId;
        if (rawAdPrefs is Map) {
          final rawMap = rawAdPrefs['rewardedCosmeticProgress'];
          if (rawMap is Map) {
            remoteProgress = rawMap.map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
            );
          }
        }
        final remoteEquipped = data['activeCosmetics'] is Map
            ? EquippedCosmetics.fromMap(
                Map<String, dynamic>.from(data['activeCosmetics'] as Map),
              )
            : state.equipped;

        state = state.copyWith(
          purchasedProductIds: {...state.purchasedProductIds, ...remoteOwned},
          rewardedProgressByProductId: remoteProgress,
          equipped: remoteEquipped,
        );
        _saveLocalCache();
      }, onError: (_) {});
    } catch (_) {}
  }

  FirebaseFirestore? _tryGetDefaultFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Returns whether the user permanently owns [productId].
  bool isPermanentlyOwned(String productId) =>
      state.purchasedProductIds.contains(productId);

  /// Returns whether the user can currently use/equip [item]
  /// (either permanently owned OR included with an active Football SOS Pro subscription).
  bool isUnlocked(CosmeticItem item, {required bool isProActive}) {
    if (state.purchasedProductIds.contains(item.productId)) return true;
    if (item.includedWithPro && isProActive) return true;
    return false;
  }

  /// Grants permanent ownership of [productIds] after verified purchase or restore.
  Future<void> grantVerifiedCosmetics(Iterable<String> productIds) async {
    final updated = <String>{...state.purchasedProductIds, ...productIds};
    state = state.copyWith(purchasedProductIds: updated);
    await _saveLocalCache();
  }

  /// Records a verified rewarded ad completion toward [item].
  /// When progress reaches [CosmeticItem.rewardedAdsRequired], the cosmetic is permanently unlocked.
  Future<bool> recordVerifiedRewardedAdProgress(CosmeticItem item) async {
    final target = item.rewardedAdsRequired ?? 3;
    final current = state.rewardedProgressByProductId[item.productId] ?? 0;
    final next = current + 1;
    final updatedProgress = Map<String, int>.from(
      state.rewardedProgressByProductId,
    )..[item.productId] = next;

    var unlockedNow = false;
    var updatedOwned = state.purchasedProductIds;
    if (next >= target && !updatedOwned.contains(item.productId)) {
      updatedOwned = <String>{...updatedOwned, item.productId};
      unlockedNow = true;
    }

    state = state.copyWith(
      purchasedProductIds: updatedOwned,
      rewardedProgressByProductId: updatedProgress,
    );
    await _saveLocalCache();
    await _syncAdProgressAndActiveThemeToFirestore();
    return unlockedNow;
  }

  /// Equips an unlocked cosmetic item and syncs `activeCosmetics` to Firestore.
  Future<bool> equipItem(CosmeticItem item, {required bool isProActive}) async {
    if (!isUnlocked(item, isProActive: isProActive)) {
      return false;
    }

    final nextEquipped = switch (item.category) {
      CosmeticCategory.pitchTheme => state.equipped.copyWith(
        pitchThemeId: item.id,
      ),
      CosmeticCategory.boardTheme => state.equipped.copyWith(
        boardThemeId: item.id,
      ),
      CosmeticCategory.profileFrame => state.equipped.copyWith(
        profileFrameId: item.id,
      ),
      CosmeticCategory.avatar => state.equipped.copyWith(avatarId: item.id),
      CosmeticCategory.badge => state.equipped.copyWith(badgeId: item.id),
      CosmeticCategory.seasonal => state.equipped.copyWith(
        seasonalEffectId: item.id,
      ),
    };

    state = state.copyWith(equipped: nextEquipped);
    await _saveLocalCache();
    await _syncAdProgressAndActiveThemeToFirestore();
    return true;
  }

  Future<void> _syncAdProgressAndActiveThemeToFirestore() async {
    if (_uid == null || _uid.isEmpty) return;
    final fs = _firestore ?? _tryGetDefaultFirestore();
    if (fs == null) return;

    try {
      await fs.collection('users').doc(_uid).set({
        'activeCosmetics': state.equipped.toMap(),
        'activeTheme': state.equipped.boardThemeId,
        'adPreferences': {
          'rewardedCosmeticProgress': state.rewardedProgressByProductId,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Returns active accent border color for the 3x3 board based on equipped board theme.
  Color resolveBoardAccentColor({required bool isProActive}) {
    final boardId = state.equipped.boardThemeId;
    if (boardId == 'board_royal_gold' &&
        (isPermanentlyOwned(MonetizationProductIds.boardRoyalGold) ||
            isProActive)) {
      return AppColors.trophyGold;
    }
    return AppColors.electricLime;
  }

  /// Returns active profile frame border color based on equipped frame.
  Color resolveProfileFrameColor({required bool isProActive}) {
    final frameId = state.equipped.profileFrameId;
    if (frameId == 'frame_ballon_dor' &&
        (isPermanentlyOwned(MonetizationProductIds.frameBallonDor) ||
            isProActive)) {
      return AppColors.trophyGold;
    }
    if (frameId == 'frame_emerald_captain' &&
        isPermanentlyOwned(MonetizationProductIds.frameEmeraldCaptain)) {
      return AppColors.electricLime;
    }
    return isProActive ? AppColors.trophyGold : AppColors.electricLime;
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}

final cosmeticStoreServiceProvider =
    StateNotifierProvider<CosmeticStoreService, CosmeticStoreState>((ref) {
      final user = ref.watch(currentUserProvider);
      return CosmeticStoreService(uid: user?.uid);
    });

/// Filtered list of store items respecting Remote Config `disabledProductIds`.
final activeCosmeticCatalogProvider = Provider<List<CosmeticItem>>((ref) {
  final remoteConfig = ref.watch(monetizationRemoteConfigProvider);
  return CosmeticStoreService.catalog
      .where((item) => remoteConfig.isProductActive(item.productId))
      .toList();
});
