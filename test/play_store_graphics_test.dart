@Tags(['generator'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/core/theme/app_theme.dart';
import 'package:football_tic_tac_toe/core/widgets/stadium_visuals.dart';

Future<void> _loadFonts() async {
  Future<void> registerFont(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final bytes = file.readAsBytesSync();
    final loader = FontLoader(family);
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await registerFont('Sora', 'assets/fonts/Sora.ttf');
  await registerFont('Manrope', 'assets/fonts/Manrope.ttf');
  await registerFont('SpaceGrotesk', 'assets/fonts/SpaceGrotesk.ttf');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generates 512x512 App Icon and 6 localized 1024x500 Feature Graphics for Google Play', (tester) async {
    await _loadFonts();

    const locales = <String, (String, String)>{
      'tr-TR': (
        '3x3 FOOTBALL SOS & 7 FUTBOL MODU',
        'Futbol Bilgini Canlı 1v1 Arenada Kanıtla!',
      ),
      'en-US': (
        '3x3 FOOTBALL SOS & 7 FOOTBALL MODES',
        'Prove Your Football IQ in the Live 1v1 Arena!',
      ),
      'es-ES': (
        'FOOTBALL SOS 3x3 Y 7 MODOS DE FÚTBOL',
        '¡Demuestra tu IQ Futbolero en la Arena 1v1!',
      ),
      'fr-FR': (
        'FOOTBALL SOS 3x3 & 7 MODES DE FOOT',
        'Prouvez votre QI Foot dans l’Arène 1v1 !',
      ),
      'de-DE': (
        '3x3 FOOTBALL SOS & 7 FUSSBALL-MODI',
        'Beweise deinen Fußball-IQ in der 1v1-Arena!',
      ),
      'it-IT': (
        'FOOTBALL SOS 3x3 E 7 MODALITÀ CALCIO',
        'Dimostra il tuo QI Calcistico nell’Arena 1v1!',
      ),
    };

    // 1. Render 512x512 App Icon
    final iconBytes = await _captureWidgetPng(
      tester: tester,
      size: const Size(512, 512),
      pixelRatio: 1.0,
      child: Container(
        width: 512,
        height: 512,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.95,
            colors: [
              Color(0xFF163D2A),
              Color(0xFF0A1C13),
              Color(0xFF06110B),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: const GoalverseEmblem(size: 380, showGlow: true),
      ),
    );

    // 2. Render 1024x500 Feature Graphic for each locale
    for (final entry in locales.entries) {
      final locale = entry.key;
      final badge = entry.value.$1;
      final subtitle = entry.value.$2;

      final imagesDir = Directory(
        'android/fastlane/metadata/android/$locale/images',
      )..createSync(recursive: true);

      final iconFile = File('${imagesDir.path}/icon.png');
      final featureFile = File('${imagesDir.path}/featureGraphic.png');

      final featureBytes = await _captureWidgetPng(
        tester: tester,
        size: const Size(1024, 500),
        pixelRatio: 1.0,
        child: Scaffold(
          backgroundColor: const Color(0xFF07130D),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF123624),
                      Color(0xFF091B12),
                      Color(0xFF050E09),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 42),
                child: Row(
                  children: [
                    const GoalverseEmblem(size: 168, showGlow: true),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'GOALVERSE: FOOTBALL SOS',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.trophyGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      await tester.runAsync(() async {
        await iconFile.writeAsBytes(iconBytes, flush: true);
        await featureFile.writeAsBytes(featureBytes, flush: true);
      });
    }
  });
}

Future<Uint8List> _captureWidgetPng({
  required WidgetTester tester,
  required Size size,
  required double pixelRatio,
  required Widget child,
}) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = Size(size.width * pixelRatio, size.height * pixelRatio);
  tester.view.devicePixelRatio = pixelRatio;

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: RepaintBoundary(key: key, child: child),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));

  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final bytes = await tester.runAsync<Uint8List>(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bd = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bd!.buffer.asUint8List();
  });
  return bytes!;
}

