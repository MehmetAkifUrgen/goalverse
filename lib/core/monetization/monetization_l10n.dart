import 'package:flutter/widgets.dart';

/// Multi-language localization provider for Football SOS Monetization,
/// Premium Paywall, Cosmetic Store, and Ad flows across 6 languages:
/// Turkish (tr), English (en), Spanish (es), French (fr), German (de), Italian (it).
class MonetizationL10n {
  final String languageCode;

  const MonetizationL10n(this.languageCode);

  factory MonetizationL10n.of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    final code = (locale?.languageCode ?? 'tr').toLowerCase();
    if (_translations.containsKey(code)) {
      return MonetizationL10n(code);
    }
    return const MonetizationL10n('tr');
  }

  String tr(String key, [Map<String, String>? params]) {
    final langMap = _translations[languageCode] ?? _translations['tr']!;
    var value = langMap[key] ?? _translations['tr']![key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }

  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      'pro_title': 'Football SOS Pro',
      'pro_subtitle':
          'Reklamsız stadyum atmosferi, özel saha/tahta temaları, gelişmiş maç analitiği ve şampiyon profil rozetleri.',
      'pro_badge': 'PRO',
      'pro_active_badge': 'FOOTBALL SOS PRO AKTİF',
      'pro_fair_play_notice':
          'Adil Rekabet Garantisi: Football SOS Pro hiçbir rekabet avantajı sağlamaz. ELO puanı, cevap süresi, pas hakları ve oyun kuralları tüm oyuncular için eşittir.',
      'pro_benefit_no_ads': 'Tüm Banner ve Maç Sonu Reklamlarının Kaldırılması',
      'pro_benefit_frames': 'Özel Şampiyon Profil Çerçeveleri',
      'pro_benefit_badge':
          'Profil ve Liderlik Tablosunda Football SOS Pro Rozeti',
      'pro_benefit_board_themes':
          'Özel 3×3 Oyun Tahtası ve Stadyum Çim Temaları',
      'pro_benefit_detailed_stats':
          'Detaylı Maç İstatistikleri ve Performans Analizi',
      'pro_benefit_extended_history': 'Genişletilmiş Maç Geçmişi (Son 50 Maç)',
      'pro_benefit_profile_customization':
          'Tam Profil Kişiselleştirme ve Ödüllü Kozmetiklere Anında Erişim',
      'plan_monthly_title': 'Aylık Premium',
      'plan_monthly_subtitle':
          'Her ay otomatik yenilenir • İstediğin zaman iptal et',
      'plan_yearly_title': 'Yıllık Premium',
      'plan_yearly_subtitle': '12 ay tam erişim • En avantajlı sezon paketi',
      'plan_best_value': 'EN AVANTAJLI',
      'price_loading': 'Mağaza fiyatı alınıyor...',
      'price_unavailable': 'Mağaza bağlantısı bekleniyor',
      'buy_pro_button': 'Football SOS Pro\'ya Katıl',
      'restore_purchases': 'Satın Alımları Geri Yükle',
      'manage_subscription': 'Abonelik Yönetimi',
      'terms_of_use': 'Kullanım Şartları',
      'privacy_policy': 'Gizlilik Politikası',
      'status_active': 'Aktif Abonelik',
      'status_active_until_expiry': 'İptal Edildi • Dönem Sonuna Kadar Aktif',
      'status_grace_period': 'Ödeme Bekleniyor • Ek Süre Aktif',
      'status_billing_retry': 'Ödeme Başarısız • Ödeme Yöntemini Güncelleyin',
      'status_expired': 'Abonelik Süresi Doldu',
      'status_none': 'Ücretsiz Plan',
      'store_title': 'Kozmetik Mağazası',
      'store_subtitle':
          'Saha, oyun tahtası ve profil görünümünü kişiselleştir. Hiçbir ürün oyun içi rekabet avantajı sağlamaz.',
      'cat_pitch_theme': 'Saha Temaları',
      'cat_board_theme': 'Oyun Tahtası Temaları',
      'cat_profile_frame': 'Profil Çerçeveleri',
      'cat_avatar': 'Avatarlar',
      'cat_badge': 'Özel Rozetler',
      'cat_seasonal': 'Sezonluk Kozmetikler',
      'owned_badge': 'SAHİPSİN',
      'equipped_badge': 'AKTİF',
      'included_with_pro': 'PRO İLE AÇIK',
      'equip_button': 'Kullan',
      'buy_cosmetic_button': 'Satın Al ({price})',
      'watch_ad_unlock': 'Reklam İzle ({current}/{target})',
      'watch_ad_cta': 'Ödüllü Reklam İzle (+1 Kozmetik İlerlemesi)',
      'ad_sponsored_label': 'SPONSORLU REKLAM • REKLAMLARI KALDIR',
      'purchase_success': 'Satın alma doğrulandı ve hesabınıza tanımlandı!',
      'purchase_cancelled': 'Satın alma işlemi iptal edildi.',
      'purchase_already_owned': 'Bu ürüne zaten sahipsiniz.',
      'purchase_failed': 'Ödeme işlemi tamamlanamadı. Lütfen tekrar deneyin.',
      'purchase_pending': 'Ödeme işlemi onay bekliyor.',
      'restore_success':
          'Satın alımlarınız ve abonelikleriniz başarıyla geri yüklendi.',
      'restore_empty':
          'Bu hesap için geri yüklenecek aktif satın alım bulunamadı.',
      'rewarded_ad_completed':
          'Tebrikler! Ödüllü reklam tamamlandı ve kozmetik ilerlemeniz eklendi.',
      'rewarded_ad_incomplete':
          'Reklam tamamlanmadan kapatıldığı için ödül verilmedi.',
      'detailed_stats_title': 'PRO DETAYLI MAÇ ANALİTİĞİ',
      'detailed_stats_locked':
          'Mod bazlı analiz ve 50 maçlık geçmiş Football SOS Pro ile açılır.',
      'item_pitch_champions_title': 'Şampiyonlar Gecesi Sahası',
      'item_pitch_champions_desc':
          'Gece projektörleri ve zümrüt çim çizgileriyle Avrupa kupası atmosferi.',
      'item_pitch_golden_title': 'Altın Final Stadyumu',
      'item_pitch_golden_desc':
          'Final maçlarına özel altın saha çizgileri ve kupa ambiyansı.',
      'item_board_neon_title': 'Elektrik Lime Taktik Tahtası',
      'item_board_neon_desc':
          'Yüksek kontrastlı taktik neon çerçeveli 3×3 SOS tahtası.',
      'item_board_royal_title': 'Kraliyet Altın 3×3 Tahtası',
      'item_board_royal_desc':
          'Şampiyon kulüplere özel altın işlemeli 3×3 maç tahtası.',
      'item_frame_ballon_title': 'Altın Top Çerçevesi',
      'item_frame_ballon_desc':
          'Yılın futbolcusuna özel parlayan altın profil çerçevesi.',
      'item_frame_emerald_title': 'Zümrüt Kaptan Çerçevesi',
      'item_frame_emerald_desc':
          'Takım kaptanlarına özel çim yeşili stadyum çerçevesi.',
      'item_avatar_striker_title': 'Efsane Santrafor #9',
      'item_avatar_striker_desc':
          'Ceza sahası golcüsü özel oyuncu kartı avatarı.',
      'item_avatar_maestro_title': 'Orta Saha Maestrosu #10',
      'item_avatar_maestro_desc':
          'Oyun kurucu 10 numara özel oyuncu kartı avatarı.',
      'item_badge_tactical_title': 'Taktik Dehası Rozeti',
      'item_badge_tactical_desc':
          'Profil kartında ve maç ekranında görünen taktik ustası rozeti.',
      'item_badge_unbeaten_title': 'Yenilmezler Kulübü Rozeti',
      'item_badge_unbeaten_desc': 'Namağlup şampiyonlara özel prestij rozeti.',
      'item_season1_derby_title': 'Sezon 1 Derbi Koleksiyonu',
      'item_season1_derby_desc':
          'Sezon 1 derbi haftasına özel sınırlı üretim stadyum efekti.',
      'item_season1_aura_title': 'Sezon 1 Kupa Aurası',
      'item_season1_aura_desc':
          'Profil ve maç sonu ekranında parlayan Sezon 1 kupa aurası.',
    },
    'en': {
      'pro_title': 'Football SOS Pro',
      'pro_subtitle':
          'Ad-free stadium atmosphere, exclusive pitch & board themes, advanced match analytics, and champion profile badges.',
      'pro_badge': 'PRO',
      'pro_active_badge': 'FOOTBALL SOS PRO ACTIVE',
      'pro_fair_play_notice':
          'Fair Play Guarantee: Football SOS Pro grants zero competitive advantage. ELO rating, turn timers, passes, and game rules are identical for everyone.',
      'pro_benefit_no_ads': 'Remove All Banner & Post-Match Interstitial Ads',
      'pro_benefit_frames': 'Exclusive Champion Profile Frames',
      'pro_benefit_badge': 'Football SOS Pro Badge on Profile & Leaderboards',
      'pro_benefit_board_themes': 'Exclusive 3×3 Board & Stadium Pitch Themes',
      'pro_benefit_detailed_stats':
          'Detailed Match Analytics & Performance Breakdown',
      'pro_benefit_extended_history':
          'Extended Match History (Last 50 Matches)',
      'pro_benefit_profile_customization':
          'Full Profile Customization & Instant Rewarded Cosmetics',
      'plan_monthly_title': 'Monthly Premium',
      'plan_monthly_subtitle': 'Auto-renews monthly • Cancel anytime',
      'plan_yearly_title': 'Yearly Premium',
      'plan_yearly_subtitle': '12 months full access • Best value season pass',
      'plan_best_value': 'BEST VALUE',
      'price_loading': 'Fetching store price...',
      'price_unavailable': 'Waiting for store connection',
      'buy_pro_button': 'Join Football SOS Pro',
      'restore_purchases': 'Restore Purchases',
      'manage_subscription': 'Manage Subscription',
      'terms_of_use': 'Terms of Use',
      'privacy_policy': 'Privacy Policy',
      'status_active': 'Active Subscription',
      'status_active_until_expiry': 'Cancelled • Active Until Period End',
      'status_grace_period': 'Payment Issue • Grace Period Active',
      'status_billing_retry': 'Payment Failed • Update Payment Method',
      'status_expired': 'Subscription Expired',
      'status_none': 'Free Plan',
      'store_title': 'Cosmetic Store',
      'store_subtitle':
          'Customize your pitch, game board, and profile look. All items are purely cosmetic with zero competitive advantage.',
      'cat_pitch_theme': 'Pitch Themes',
      'cat_board_theme': 'Board Themes',
      'cat_profile_frame': 'Profile Frames',
      'cat_avatar': 'Avatars',
      'cat_badge': 'Custom Badges',
      'cat_seasonal': 'Seasonal Cosmetics',
      'owned_badge': 'OWNED',
      'equipped_badge': 'EQUIPPED',
      'included_with_pro': 'INCLUDED IN PRO',
      'equip_button': 'Equip',
      'buy_cosmetic_button': 'Buy ({price})',
      'watch_ad_unlock': 'Watch Ad ({current}/{target})',
      'watch_ad_cta': 'Watch Rewarded Ad (+1 Cosmetic Progress)',
      'ad_sponsored_label': 'SPONSORED AD • REMOVE ADS',
      'purchase_success': 'Purchase verified and unlocked on your account!',
      'purchase_cancelled': 'Purchase was cancelled.',
      'purchase_already_owned': 'You already own this item.',
      'purchase_failed': 'Payment could not be completed. Please try again.',
      'purchase_pending': 'Payment is pending confirmation.',
      'restore_success': 'Your purchases and subscriptions have been restored.',
      'restore_empty': 'No active purchases found to restore for this account.',
      'rewarded_ad_completed':
          'Rewarded ad completed! Cosmetic progress granted.',
      'rewarded_ad_incomplete':
          'Ad closed before completion. No reward granted.',
      'detailed_stats_title': 'PRO DETAILED MATCH ANALYTICS',
      'detailed_stats_locked':
          'Unlock mode breakdown & 50-match history with Football SOS Pro.',
      'item_pitch_champions_title': 'Champions Night Pitch',
      'item_pitch_champions_desc':
          'European night floodlights with emerald turf lines.',
      'item_pitch_golden_title': 'Golden Final Stadium',
      'item_pitch_golden_desc':
          'Championship final pitch with golden touchlines.',
      'item_board_neon_title': 'Electric Lime Tactical Board',
      'item_board_neon_desc': 'High-contrast tactical neon 3×3 SOS board.',
      'item_board_royal_title': 'Royal Gold 3×3 Board',
      'item_board_royal_desc':
          'Gold-trimmed 3×3 match board for champion clubs.',
      'item_frame_ballon_title': 'Ballon d\'Or Frame',
      'item_frame_ballon_desc':
          'Glowing golden profile frame for top footballers.',
      'item_frame_emerald_title': 'Emerald Captain Frame',
      'item_frame_emerald_desc':
          'Turf green stadium armband frame for team captains.',
      'item_avatar_striker_title': 'Legendary Striker #9',
      'item_avatar_striker_desc': 'Clinical #9 finisher player card avatar.',
      'item_avatar_maestro_title': 'Midfield Maestro #10',
      'item_avatar_maestro_desc': 'Playmaker #10 icon player card avatar.',
      'item_badge_tactical_title': 'Tactical Genius Badge',
      'item_badge_tactical_desc':
          'Master tactician badge displayed on profile & matches.',
      'item_badge_unbeaten_title': 'Invincibles Club Badge',
      'item_badge_unbeaten_desc': 'Prestige badge for unbeaten champions.',
      'item_season1_derby_title': 'Season 1 Derby Collection',
      'item_season1_derby_desc':
          'Limited-edition Season 1 Derby Week stadium effect.',
      'item_season1_aura_title': 'Season 1 Trophy Aura',
      'item_season1_aura_desc':
          'Glowing Season 1 trophy aura on profile and match summary.',
    },
    'es': {
      'pro_title': 'Football SOS Pro',
      'pro_subtitle':
          'Experiencia sin anuncios, temas exclusivos de campo y tablero, estadísticas avanzadas e insignias Pro.',
      'pro_badge': 'PRO',
      'pro_active_badge': 'FOOTBALL SOS PRO ACTIVO',
      'pro_fair_play_notice':
          'Juego Limpio Garantizado: Football SOS Pro no otorga ventaja competitiva. ELO, tiempo y reglas son iguales para todos.',
      'pro_benefit_no_ads':
          'Eliminación de todos los anuncios Banner e Interstitial',
      'pro_benefit_frames': 'Marcos de perfil exclusivos de campeón',
      'pro_benefit_badge':
          'Insignia Football SOS Pro en perfil y clasificación',
      'pro_benefit_board_themes':
          'Temas exclusivos para el tablero 3×3 y césped',
      'pro_benefit_detailed_stats': 'Estadísticas de partido detalladas',
      'pro_benefit_extended_history':
          'Historial de partidos ampliado (Últimos 50)',
      'pro_benefit_profile_customization':
          'Personalización completa del perfil',
      'plan_monthly_title': 'Premium Mensual',
      'plan_monthly_subtitle': 'Renovación mensual • Cancela cuando quieras',
      'plan_yearly_title': 'Premium Anual',
      'plan_yearly_subtitle': '12 meses de acceso total • Mejor valor',
      'plan_best_value': 'MEJOR VALOR',
      'price_loading': 'Obteniendo precio de la tienda...',
      'price_unavailable': 'Esperando conexión con la tienda',
      'buy_pro_button': 'Unirse a Football SOS Pro',
      'restore_purchases': 'Restaurar compras',
      'manage_subscription': 'Gestionar suscripción',
      'terms_of_use': 'Términos de uso',
      'privacy_policy': 'Política de privacidad',
      'status_active': 'Suscripción activa',
      'status_active_until_expiry': 'Cancelada • Activa hasta fin de periodo',
      'status_grace_period': 'Problema de pago • Periodo de gracia activo',
      'status_billing_retry': 'Pago fallido • Actualiza tu método de pago',
      'status_expired': 'Suscripción expirada',
      'status_none': 'Plan Gratuito',
      'store_title': 'Tienda Cosmética',
      'store_subtitle':
          'Personaliza tu estadio, tablero y perfil sin ventajas competitivas.',
      'cat_pitch_theme': 'Temas de Campo',
      'cat_board_theme': 'Temas de Tablero',
      'cat_profile_frame': 'Marcos de Perfil',
      'cat_avatar': 'Avatares',
      'cat_badge': 'Insignias',
      'cat_seasonal': 'Cosméticos de Temporada',
      'owned_badge': 'ADQUIRIDO',
      'equipped_badge': 'EQUIPADO',
      'included_with_pro': 'INCLUIDO EN PRO',
      'equip_button': 'Equipar',
      'buy_cosmetic_button': 'Comprar ({price})',
      'watch_ad_unlock': 'Ver anuncio ({current}/{target})',
      'watch_ad_cta': 'Ver anuncio con recompensa (+1 progreso)',
      'ad_sponsored_label': 'ANUNCIO PATROCINADO • QUITAR ANUNCIOS',
      'purchase_success': '¡Compra verificada y activada en tu cuenta!',
      'purchase_cancelled': 'La compra fue cancelada.',
      'purchase_already_owned': 'Ya posees este artículo.',
      'purchase_failed': 'No se pudo completar el pago.',
      'purchase_pending': 'Pago pendiente de confirmación.',
      'restore_success': 'Tus compras han sido restauradas.',
      'restore_empty': 'No se encontraron compras activas para restaurar.',
      'rewarded_ad_completed':
          '¡Anuncio completado! Recompensa cosmética añadida.',
      'rewarded_ad_incomplete':
          'Anuncio cerrado antes de terminar. Sin recompensa.',
      'detailed_stats_title': 'ESTADÍSTICAS DETALLADAS PRO',
      'detailed_stats_locked':
          'Desbloquea análisis avanzado e historial de 50 partidos con Pro.',
      'item_pitch_champions_title': 'Campo Noche de Campeones',
      'item_pitch_champions_desc':
          'Focos nocturnos europeos con césped esmeralda.',
      'item_pitch_golden_title': 'Estadio Final Dorada',
      'item_pitch_golden_desc': 'Líneas doradas de gran final.',
      'item_board_neon_title': 'Tablero Táctico Lima Eléctrico',
      'item_board_neon_desc': 'Tablero 3×3 de alto contraste táctico.',
      'item_board_royal_title': 'Tablero Real Dorado 3×3',
      'item_board_royal_desc': 'Tablero con detalles dorados de campeón.',
      'item_frame_ballon_title': 'Marco Balón de Oro',
      'item_frame_ballon_desc': 'Marco dorado brillante para leyendas.',
      'item_frame_emerald_title': 'Marco Capitán Esmeralda',
      'item_frame_emerald_desc': 'Marco verde césped para capitanes.',
      'item_avatar_striker_title': 'Delantero Leyenda #9',
      'item_avatar_striker_desc': 'Avatar de goleador #9.',
      'item_avatar_maestro_title': 'Maestro del Mediocampo #10',
      'item_avatar_maestro_desc': 'Avatar de creador de juego #10.',
      'item_badge_tactical_title': 'Insignia Genio Táctico',
      'item_badge_tactical_desc': 'Insignia de estratega en tu perfil.',
      'item_badge_unbeaten_title': 'Insignia Club Invicto',
      'item_badge_unbeaten_desc':
          'Insignia de prestigio para campeones invictos.',
      'item_season1_derby_title': 'Colección Derbi Temporada 1',
      'item_season1_derby_desc': 'Efecto exclusivo de la Semana de Derbi.',
      'item_season1_aura_title': 'Aura de Trofeo Temporada 1',
      'item_season1_aura_desc': 'Aura dorada de trofeo en perfil y resumen.',
    },
    'fr': {
      'pro_title': 'Football SOS Pro',
      'pro_subtitle':
          'Expérience sans publicité, thèmes de terrain et plateau exclusifs, statistiques détaillées et badges Pro.',
      'pro_badge': 'PRO',
      'pro_active_badge': 'FOOTBALL SOS PRO ACTIF',
      'pro_fair_play_notice':
          'Garantie Fair-Play : Football SOS Pro n\'offre aucun avantage compétitif. L\'ELO, le chronomètre et les règles sont identiques pour tous.',
      'pro_benefit_no_ads': 'Suppression de toutes les publicités',
      'pro_benefit_frames': 'Cadres de profil exclusifs de champion',
      'pro_benefit_badge':
          'Badge Football SOS Pro sur le profil et le classement',
      'pro_benefit_board_themes':
          'Thèmes exclusifs de plateau 3×3 et de pelouse',
      'pro_benefit_detailed_stats': 'Statistiques de match détaillées',
      'pro_benefit_extended_history':
          'Historique de matchs étendu (50 derniers)',
      'pro_benefit_profile_customization':
          'Personnalisation complète du profil',
      'plan_monthly_title': 'Premium Mensuel',
      'plan_monthly_subtitle': 'Renouvellement mensuel • Annulez à tout moment',
      'plan_yearly_title': 'Premium Annuel',
      'plan_yearly_subtitle': '12 mois d\'accès complet • Meilleure offre',
      'plan_best_value': 'MEILLEURE OFFRE',
      'price_loading': 'Chargement du prix...',
      'price_unavailable': 'En attente de la boutique',
      'buy_pro_button': 'Rejoindre Football SOS Pro',
      'restore_purchases': 'Restaurer les achats',
      'manage_subscription': 'Gérer l\'abonnement',
      'terms_of_use': 'Conditions d\'utilisation',
      'privacy_policy': 'Politique de confidentialité',
      'status_active': 'Abonnement actif',
      'status_active_until_expiry':
          'Annulé • Actif jusqu\'à la fin de la période',
      'status_grace_period': 'Problème de paiement • Période de grâce active',
      'status_billing_retry':
          'Échec du paiement • Mettez à jour votre moyen de paiement',
      'status_expired': 'Abonnement expiré',
      'status_none': 'Forfait Gratuit',
      'store_title': 'Boutique Cosmétique',
      'store_subtitle':
          'Personnalisez votre terrain, plateau et profil sans avantage compétitif.',
      'cat_pitch_theme': 'Thèmes de Terrain',
      'cat_board_theme': 'Thèmes de Plateau',
      'cat_profile_frame': 'Cadres de Profil',
      'cat_avatar': 'Avatars',
      'cat_badge': 'Badges Exclusifs',
      'cat_seasonal': 'Cosmétiques de Saison',
      'owned_badge': 'POSSÉDÉ',
      'equipped_badge': 'ÉQUIPÉ',
      'included_with_pro': 'INCLUS DANS PRO',
      'equip_button': 'Équiper',
      'buy_cosmetic_button': 'Acheter ({price})',
      'watch_ad_unlock': 'Voir pub ({current}/{target})',
      'watch_ad_cta': 'Regarder une pub (+1 progression cosmétique)',
      'ad_sponsored_label': 'PUBLICITÉ • SUPPRIMER LES PUBS',
      'purchase_success': 'Achat vérifié et activé sur votre compte !',
      'purchase_cancelled': 'L\'achat a été annulé.',
      'purchase_already_owned': 'Vous possédez déjà cet article.',
      'purchase_failed': 'Le paiement n\'a pas pu être effectué.',
      'purchase_pending': 'Paiement en attente de confirmation.',
      'restore_success': 'Vos achats ont été restaurés avec succès.',
      'restore_empty': 'Aucun achat actif trouvé pour ce compte.',
      'rewarded_ad_completed':
          'Publicité terminée ! Récompense cosmétique accordée.',
      'rewarded_ad_incomplete':
          'Publicité fermée avant la fin. Aucune récompense.',
      'detailed_stats_title': 'STATISTIQUES DÉTAILLÉES PRO',
      'detailed_stats_locked':
          'Débloquez l\'analyse détaillée et l\'historique de 50 matchs avec Pro.',
      'item_pitch_champions_title': 'Terrain Nuit des Champions',
      'item_pitch_champions_desc':
          'Projecteurs nocturnes européens et pelouse émeraude.',
      'item_pitch_golden_title': 'Stade Finale d\'Or',
      'item_pitch_golden_desc': 'Terrain de grande finale aux lignes dorées.',
      'item_board_neon_title': 'Plateau Tactique Citron Électrique',
      'item_board_neon_desc': 'Plateau 3×3 tactique à haut contraste.',
      'item_board_royal_title': 'Plateau Royal Or 3×3',
      'item_board_royal_desc': 'Plateau 3×3 orné d\'or pour les champions.',
      'item_frame_ballon_title': 'Cadre Ballon d\'Or',
      'item_frame_ballon_desc': 'Cadre de profil doré étincelant.',
      'item_frame_emerald_title': 'Cadre Capitaine Émeraude',
      'item_frame_emerald_desc': 'Cadre vert pelouse pour les capitaines.',
      'item_avatar_striker_title': 'Buteur Légendaire #9',
      'item_avatar_striker_desc': 'Avatar carte joueur finisseur #9.',
      'item_avatar_maestro_title': 'Maestro du Milieu #10',
      'item_avatar_maestro_desc': 'Avatar carte joueur meneur #10.',
      'item_badge_tactical_title': 'Badge Génie Tactique',
      'item_badge_tactical_desc': 'Badge de maître tacticien sur votre profil.',
      'item_badge_unbeaten_title': 'Badge Club des Invincibles',
      'item_badge_unbeaten_desc':
          'Badge de prestige pour les champions invaincus.',
      'item_season1_derby_title': 'Collection Derby Saison 1',
      'item_season1_derby_desc': 'Effet de stade limité Semaine de Derby.',
      'item_season1_aura_title': 'Aura Trophée Saison 1',
      'item_season1_aura_desc': 'Aura de trophée Saison 1 sur le profil.',
    },
    'de': {
      'pro_title': 'Football SOS Pro',
      'pro_subtitle':
          'Werbefreies Stadionerlebnis, exklusive Rasen- & Spielfeld-Designs, detaillierte Spielstatistiken und Pro-Abzeichen.',
      'pro_badge': 'PRO',
      'pro_active_badge': 'FOOTBALL SOS PRO AKTIV',
      'pro_fair_play_notice':
          'Fair-Play-Garantie: Football SOS Pro bietet keinerlei spielerische Vorteile. ELO, Bedenkzeit und Spielregeln sind für alle identisch.',
      'pro_benefit_no_ads': 'Keine Banner- und Vollbildwerbung nach Spielen',
      'pro_benefit_frames': 'Exklusive Champion-Profilrahmen',
      'pro_benefit_badge':
          'Football SOS Pro-Abzeichen im Profil & auf Bestenlisten',
      'pro_benefit_board_themes':
          'Exklusive 3×3-Spielfeld- & Stadionrasen-Designs',
      'pro_benefit_detailed_stats':
          'Detaillierte Spielstatistiken & Leistungsanalyse',
      'pro_benefit_extended_history':
          'Erweiterter Spielverlauf (Letzte 50 Spiele)',
      'pro_benefit_profile_customization': 'Volle Profil-Personalisierung',
      'plan_monthly_title': 'Monatliches Premium',
      'plan_monthly_subtitle': 'Monatlich kündbar • Automatische Verlängerung',
      'plan_yearly_title': 'Jährliches Premium',
      'plan_yearly_subtitle':
          '12 Monate Vollzugriff • Bestes Preis-Leistungs-Verhältnis',
      'plan_best_value': 'BESTES ANGEBOT',
      'price_loading': 'Store-Preis wird geladen...',
      'price_unavailable': 'Warte auf Store-Verbindung',
      'buy_pro_button': 'Football SOS Pro holen',
      'restore_purchases': 'Käufe wiederherstellen',
      'manage_subscription': 'Abo verwalten',
      'terms_of_use': 'Nutzungsbedingungen',
      'privacy_policy': 'Datenschutzerklärung',
      'status_active': 'Aktives Abonnement',
      'status_active_until_expiry': 'Gekündigt • Aktiv bis Laufzeitende',
      'status_grace_period': 'Zahlungsproblem • Kulanzfrist aktiv',
      'status_billing_retry': 'Zahlung fehlgeschlagen • Zahlungsmethode prüfen',
      'status_expired': 'Abonnement abgelaufen',
      'status_none': 'Kostenloser Tarif',
      'store_title': 'Kosmetik-Shop',
      'store_subtitle':
          'Personalisiere Rasen, Spielfeld und Profil ohne Wettbewerbsvorteile.',
      'cat_pitch_theme': 'Rasen-Designs',
      'cat_board_theme': 'Spielfeld-Designs',
      'cat_profile_frame': 'Profilrahmen',
      'cat_avatar': 'Avatare',
      'cat_badge': 'Abzeichen',
      'cat_seasonal': 'Saison-Kosmetik',
      'owned_badge': 'IM BESITZ',
      'equipped_badge': 'AKTIV',
      'included_with_pro': 'IN PRO ENTHALTEN',
      'equip_button': 'Ausrüsten',
      'buy_cosmetic_button': 'Kaufen ({price})',
      'watch_ad_unlock': 'Werbung ansehen ({current}/{target})',
      'watch_ad_cta': 'Belohnungswerbung ansehen (+1 Fortschritt)',
      'ad_sponsored_label': 'ANZEIGE • WERBUNG ENTFERNEN',
      'purchase_success': 'Kauf bestätigt und für dein Konto freigeschaltet!',
      'purchase_cancelled': 'Kauf wurde abgebrochen.',
      'purchase_already_owned': 'Du besitzt diesen Artikel bereits.',
      'purchase_failed': 'Zahlung fehlgeschlagen. Bitte erneut versuchen.',
      'purchase_pending': 'Zahlung wartet auf Bestätigung.',
      'restore_success': 'Deine Käufe wurden erfolgreich wiederhergestellt.',
      'restore_empty': 'Keine aktiven Käufe für dieses Konto gefunden.',
      'rewarded_ad_completed':
          'Video abgeschlossen! Kosmetik-Fortschritt gutgeschrieben.',
      'rewarded_ad_incomplete': 'Video vorzeitig beendet. Keine Belohnung.',
      'detailed_stats_title': 'PRO DETAILLIERTE SPIELANALYSE',
      'detailed_stats_locked':
          'Schalte Detailanalyse & 50-Spiele-Verlauf mit Football SOS Pro frei.',
      'item_pitch_champions_title': 'Champions-Nacht-Rasen',
      'item_pitch_champions_desc':
          'Flutlicht-Atmosphäre mit smaragdgrünem Rasen.',
      'item_pitch_golden_title': 'Goldenes Finalstadion',
      'item_pitch_golden_desc': 'Finalplatz mit goldenen Spielfeldlinien.',
      'item_board_neon_title': 'Electric-Lime-Taktiktafel',
      'item_board_neon_desc': 'Kontraststarkes 3×3-Taktikfeld.',
      'item_board_royal_title': 'Königliches Gold-3×3-Feld',
      'item_board_royal_desc': 'Goldverziertes 3×3-Spielfeld für Meister.',
      'item_frame_ballon_title': 'Ballon d\'Or-Rahmen',
      'item_frame_ballon_desc': 'Glänzender goldener Profilrahmen.',
      'item_frame_emerald_title': 'Smaragd-Kapitänsrahmen',
      'item_frame_emerald_desc': 'Rasengrüner Rahmen für Mannschaftskapitäne.',
      'item_avatar_striker_title': 'Legendärer Stürmer #9',
      'item_avatar_striker_desc': 'Torjäger #9 Spielerkarten-Avatar.',
      'item_avatar_maestro_title': 'Mittelfeld-Maestro #10',
      'item_avatar_maestro_desc': 'Spielmacher #10 Spielerkarten-Avatar.',
      'item_badge_tactical_title': 'Taktikgenie-Abzeichen',
      'item_badge_tactical_desc': 'Meistertaktiker-Abzeichen für dein Profil.',
      'item_badge_unbeaten_title': 'Unbesiegbar-Abzeichen',
      'item_badge_unbeaten_desc':
          'Prestige-Abzeichen für ungeschlagene Champions.',
      'item_season1_derby_title': 'Saison 1 Derby-Kollektion',
      'item_season1_derby_desc': 'Limitierter Stadion-Effekt zur Derby-Woche.',
      'item_season1_aura_title': 'Saison 1 Pokal-Aura',
      'item_season1_aura_desc': 'Leuchtende Pokal-Aura im Profil.',
    },
    'it': {
      'pro_title': 'Football SOS Pro',
      'pro_subtitle':
          'Atmosfera stadio senza pubblicità, temi esclusivi per campo e griglia, statistiche avanzate e badge Pro.',
      'pro_badge': 'PRO',
      'pro_active_badge': 'FOOTBALL SOS PRO ATTIVO',
      'pro_fair_play_notice':
          'Garanzia Fair Play: Football SOS Pro non offre alcun vantaggio competitivo. ELO, timer e regole sono uguali per tutti.',
      'pro_benefit_no_ads':
          'Rimozione di tutti gli annunci Banner e Interstitial',
      'pro_benefit_frames': 'Cornici profilo esclusive da campione',
      'pro_benefit_badge': 'Badge Football SOS Pro su profilo e classifiche',
      'pro_benefit_board_themes':
          'Temi esclusivi per griglia 3×3 e manto erboso',
      'pro_benefit_detailed_stats': 'Statistiche partita dettagliate',
      'pro_benefit_extended_history': 'Cronologia partite estesa (Ultime 50)',
      'pro_benefit_profile_customization':
          'Personalizzazione completa del profilo',
      'plan_monthly_title': 'Premium Mensile',
      'plan_monthly_subtitle': 'Rinnovo mensile • Disdici quando vuoi',
      'plan_yearly_title': 'Premium Annuale',
      'plan_yearly_subtitle': '12 mesi di accesso completo • Miglior valore',
      'plan_best_value': 'MIGLIOR VALORE',
      'price_loading': 'Caricamento prezzo dallo store...',
      'price_unavailable': 'In attesa dello store',
      'buy_pro_button': 'Passa a Football SOS Pro',
      'restore_purchases': 'Ripristina acquisti',
      'manage_subscription': 'Gestisci abbonamento',
      'terms_of_use': 'Termini di utilizzo',
      'privacy_policy': 'Informativa sulla privacy',
      'status_active': 'Abbonamento attivo',
      'status_active_until_expiry': 'Disdetto • Attivo fino a fine periodo',
      'status_grace_period': 'Problema di pagamento • Periodo di grazia attivo',
      'status_billing_retry':
          'Pagamento non riuscito • Aggiorna metodo di pagamento',
      'status_expired': 'Abbonamento scaduto',
      'status_none': 'Piano Gratuito',
      'store_title': 'Negozio Cosmetico',
      'store_subtitle':
          'Personalizza campo, griglia e profilo senza vantaggi competitivi.',
      'cat_pitch_theme': 'Temi Campo',
      'cat_board_theme': 'Temi Griglia',
      'cat_profile_frame': 'Cornici Profilo',
      'cat_avatar': 'Avatar',
      'cat_badge': 'Badge Speciali',
      'cat_seasonal': 'Cosmetici Stagionali',
      'owned_badge': 'POSSEDUTO',
      'equipped_badge': 'ATTIVO',
      'included_with_pro': 'INCLUSO IN PRO',
      'equip_button': 'Equipaggia',
      'buy_cosmetic_button': 'Acquista ({price})',
      'watch_ad_unlock': 'Guarda video ({current}/{target})',
      'watch_ad_cta': 'Guarda video premiato (+1 progresso cosmetico)',
      'ad_sponsored_label': 'ANNUNCIO SPONSORIZZATO • RIMUOVI PUBBLICITÀ',
      'purchase_success': 'Acquisto verificato e attivato sul tuo account!',
      'purchase_cancelled': 'Acquisto annullato.',
      'purchase_already_owned': 'Possiedi già questo articolo.',
      'purchase_failed': 'Impossibile completare il pagamento.',
      'purchase_pending': 'Pagamento in attesa di conferma.',
      'restore_success': 'I tuoi acquisti sono stati ripristinati.',
      'restore_empty': 'Nessun acquisto attivo trovato per questo account.',
      'rewarded_ad_completed':
          'Video completato! Progresso cosmetico aggiunto.',
      'rewarded_ad_incomplete':
          'Video chiuso prima del termine. Nessun premio.',
      'detailed_stats_title': 'STATISTICHE DETTAGLIATE PRO',
      'detailed_stats_locked':
          'Sblocca analisi dettagliata e ultime 50 partite con Pro.',
      'item_pitch_champions_title': 'Campo Notte dei Campioni',
      'item_pitch_champions_desc':
          'Riflettori notturni europei ed erba smeraldo.',
      'item_pitch_golden_title': 'Stadio Finale d\'Oro',
      'item_pitch_golden_desc': 'Campo da gran finale con linee dorate.',
      'item_board_neon_title': 'Griglia Tattica Lime Elettrico',
      'item_board_neon_desc': 'Griglia 3×3 tattica ad alto contrasto.',
      'item_board_royal_title': 'Griglia Reale Oro 3×3',
      'item_board_royal_desc': 'Griglia 3×3 rifinita in oro per veri campioni.',
      'item_frame_ballon_title': 'Cornice Pallone d\'Oro',
      'item_frame_ballon_desc': 'Cornice profilo dorata lucente.',
      'item_frame_emerald_title': 'Cornice Capitano Smeraldo',
      'item_frame_emerald_desc': 'Cornice verde campo per i capitani.',
      'item_avatar_striker_title': 'Bomber Leggendario #9',
      'item_avatar_striker_desc': 'Avatar carta giocatore attaccante #9.',
      'item_avatar_maestro_title': 'Maestro del Centrocampo #10',
      'item_avatar_maestro_desc': 'Avatar carta giocatore regista #10.',
      'item_badge_tactical_title': 'Badge Genio Tattico',
      'item_badge_tactical_desc': 'Badge maestro di tattica sul profilo.',
      'item_badge_unbeaten_title': 'Badge Club degli Invincibili',
      'item_badge_unbeaten_desc': 'Badge di prestigio per campioni imbattuti.',
      'item_season1_derby_title': 'Collezione Derby Stagione 1',
      'item_season1_derby_desc': 'Effetto stadio limitato Derby Week.',
      'item_season1_aura_title': 'Aura Trofeo Stagione 1',
      'item_season1_aura_desc': 'Aura trofeo Stagione 1 sul profilo.',
    },
  };
}
