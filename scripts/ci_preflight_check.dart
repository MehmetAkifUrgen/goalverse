import 'dart:io';

/// Comprehensive Pre-Release Quality & Store Compliance Gate for Goalverse: Football SOS.
///
/// Usage:
///   dart run scripts/ci_preflight_check.dart
///   dart run scripts/ci_preflight_check.dart --track=production
void main(List<String> args) {
  final isProductionTrack =
      args.contains('--track=production') ||
      Platform.environment['RELEASE_TRACK'] == 'production';
  final confirmProduction =
      args.contains('--confirm-production') ||
      Platform.environment['CONFIRM_PRODUCTION_RELEASE'] == 'true';

  final errors = <String>[];
  final warnings = <String>[];

  stdout.writeln('===========================================================');
  stdout.writeln(' GOALVERSE: FOOTBALL SOS - PRE-RELEASE QUALITY GATE');
  stdout.writeln(
    ' Track: ${isProductionTrack ? "PRODUCTION" : "STAGING (Internal / TestFlight)"}',
  );
  stdout.writeln('===========================================================');

  // 1. Check pubspec.yaml version & build number
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    errors.add('Missing pubspec.yaml');
  } else {
    final pubspec = pubspecFile.readAsStringSync();
    final versionMatch = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    if (versionMatch == null) {
      errors.add(
        'Invalid or missing version: X.Y.Z+B in pubspec.yaml',
      );
    } else {
      final semver = versionMatch.group(1)!;
      final buildNum = int.tryParse(versionMatch.group(2)!) ?? 0;
      if (buildNum <= 0) {
        errors.add('Build number in pubspec.yaml must be > 0 (found $buildNum)');
      } else {
        stdout.writeln('[OK] App Version: $semver (Build +$buildNum)');
      }
    }
  }

  // 2. Check App Icons & Splash Screens
  const androidMipmaps = [
    'mipmap-mdpi',
    'mipmap-hdpi',
    'mipmap-xhdpi',
    'mipmap-xxhdpi',
    'mipmap-xxxhdpi',
  ];
  for (final folder in androidMipmaps) {
    final icon = File('android/app/src/main/res/$folder/ic_launcher.png');
    if (!icon.existsSync() || icon.lengthSync() == 0) {
      errors.add('Missing Android launcher icon: ${icon.path}');
    }
  }
  final iosAppIconContents = File(
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
  );
  if (!iosAppIconContents.existsSync()) {
    errors.add('Missing iOS AppIcon Contents.json: ${iosAppIconContents.path}');
  } else {
    stdout.writeln('[OK] Android & iOS App Icons verified.');
  }

  final androidSplash = File(
    'android/app/src/main/res/drawable/launch_background.xml',
  );
  final iosSplash = File('ios/Runner/Base.lproj/LaunchScreen.storyboard');
  if (!androidSplash.existsSync()) {
    errors.add('Missing Android splash configuration: ${androidSplash.path}');
  }
  if (!iosSplash.existsSync()) {
    errors.add('Missing iOS LaunchScreen.storyboard: ${iosSplash.path}');
  } else {
    stdout.writeln('[OK] Android & iOS Splash Screen configurations verified.');
  }

  // 3. Check Android applicationId & iOS PRODUCT_BUNDLE_IDENTIFIER
  final buildGradle = File('android/app/build.gradle.kts');
  final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
  final envAndroidPkg = Platform.environment['ANDROID_PACKAGE_NAME'];
  final envIosBundle = Platform.environment['IOS_BUNDLE_ID'];

  if (!buildGradle.existsSync()) {
    errors.add('Missing android/app/build.gradle.kts');
  } else {
    final gradleContent = buildGradle.readAsStringSync();
    final appIdMatch = RegExp(
      r'applicationId\s*=\s*"([^"]+)"',
    ).firstMatch(gradleContent);
    final effectiveAndroidPkg =
        (envAndroidPkg != null && envAndroidPkg.isNotEmpty)
        ? envAndroidPkg
        : appIdMatch?.group(1) ?? '';

    if (effectiveAndroidPkg.isEmpty) {
      errors.add('Could not resolve Android applicationId.');
    } else if (effectiveAndroidPkg.startsWith('com.example.')) {
      final msg =
          'Android applicationId is "$effectiveAndroidPkg" (aligned with current Firebase google-services.json). '
          'Google Play Console requires a non-com.example package name (e.g. com.goalverse.footballsos) before live store creation.';
      if (isProductionTrack) {
        errors.add(msg);
      } else {
        warnings.add(msg);
      }
    } else {
      stdout.writeln('[OK] Android Package Name: $effectiveAndroidPkg');
    }
  }

  if (!pbxproj.existsSync()) {
    errors.add('Missing ios/Runner.xcodeproj/project.pbxproj');
  } else {
    final pbxContent = pbxproj.readAsStringSync();
    final bundleMatch = RegExp(
      r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+);',
    ).firstMatch(pbxContent);
    final effectiveIosBundle =
        (envIosBundle != null && envIosBundle.isNotEmpty)
        ? envIosBundle
        : bundleMatch?.group(1)?.trim() ?? '';

    if (effectiveIosBundle.isEmpty) {
      errors.add('Could not resolve iOS PRODUCT_BUNDLE_IDENTIFIER.');
    } else if (effectiveIosBundle.startsWith('com.example.')) {
      final msg =
          'iOS PRODUCT_BUNDLE_IDENTIFIER is "$effectiveIosBundle" (aligned with current Firebase GoogleService-Info.plist). '
          'App Store Connect requires a production bundle identifier (e.g. com.goalverse.footballsos) before store submission.';
      if (isProductionTrack) {
        errors.add(msg);
      } else {
        warnings.add(msg);
      }
    } else {
      stdout.writeln('[OK] iOS Bundle Identifier: $effectiveIosBundle');
    }
  }

  // 4. Verify 6-Language Metadata Completeness & Character Limits
  const androidLocales = [
    'tr-TR',
    'en-US',
    'es-ES',
    'fr-FR',
    'de-DE',
    'it-IT',
  ];
  const iosLocales = ['tr', 'en-US', 'es-ES', 'fr-FR', 'de-DE', 'it'];

  for (final locale in androidLocales) {
    final base = 'android/fastlane/metadata/android/$locale';
    _verifyTextFile(
      path: '$base/title.txt',
      maxChars: 30,
      label: 'Android [$locale] title.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/short_description.txt',
      maxChars: 80,
      label: 'Android [$locale] short_description.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/full_description.txt',
      maxChars: 4000,
      label: 'Android [$locale] full_description.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/changelogs/default.txt',
      maxChars: 500,
      label: 'Android [$locale] changelogs/default.txt',
      errors: errors,
    );
  }

  for (final locale in iosLocales) {
    final base = 'ios/fastlane/metadata/$locale';
    _verifyTextFile(
      path: '$base/name.txt',
      maxChars: 30,
      label: 'iOS [$locale] name.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/subtitle.txt',
      maxChars: 30,
      label: 'iOS [$locale] subtitle.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/promotional_text.txt',
      maxChars: 170,
      label: 'iOS [$locale] promotional_text.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/keywords.txt',
      maxChars: 100,
      label: 'iOS [$locale] keywords.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/description.txt',
      maxChars: 4000,
      label: 'iOS [$locale] description.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/release_notes.txt',
      maxChars: 4000,
      label: 'iOS [$locale] release_notes.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/privacy_url.txt',
      maxChars: 255,
      label: 'iOS [$locale] privacy_url.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/support_url.txt',
      maxChars: 255,
      label: 'iOS [$locale] support_url.txt',
      errors: errors,
    );
    _verifyTextFile(
      path: '$base/marketing_url.txt',
      maxChars: 255,
      label: 'iOS [$locale] marketing_url.txt',
      errors: errors,
    );
  }
  stdout.writeln(
    '[OK] 6-Language Store Metadata (TR, EN, ES, FR, DE, IT) verified.',
  );

  // 5. Verify All 96 Localized Store Screenshot PNGs & Exact Dimensions
  const expectedScreens = [
    '01_home_arena',
    '02_football_sos_board',
    '03_online_match',
    '04_player_search',
    '05_match_result',
    '06_leaderboard',
    '07_profile',
    '08_daily_challenge',
  ];

  var verifiedScreenshots = 0;
  for (final locale in androidLocales) {
    for (final screen in expectedScreens) {
      final path =
          'android/fastlane/metadata/android/$locale/images/phoneScreenshots/$screen.png';
      if (_verifyPngDimensions(
        path: path,
        expectedWidth: 1080,
        expectedHeight: 1920,
        errors: errors,
      )) {
        verifiedScreenshots++;
      }
    }
  }
  for (final locale in iosLocales) {
    for (final screen in expectedScreens) {
      final path = 'ios/fastlane/screenshots/$locale/$screen.png';
      if (_verifyPngDimensions(
        path: path,
        expectedWidth: 1290,
        expectedHeight: 2796,
        errors: errors,
      )) {
        verifiedScreenshots++;
      }
    }
  }
  if (verifiedScreenshots == 96) {
    stdout.writeln(
      '[OK] All 96 Localized Store Screenshots verified (1080x1920 Android & 1290x2796 iOS 6.7").',
    );
  }

  // 6. Production manual confirmation gate
  if (isProductionTrack && !confirmProduction) {
    errors.add(
      'Production release requires explicit manual confirmation: set CONFIRM_PRODUCTION_RELEASE=true.',
    );
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('\n--- WARNINGS ---');
    for (final w in warnings) {
      stdout.writeln(' [WARN] $w');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('\n--- PRE-FLIGHT ERRORS (RELEASE BLOCKED) ---');
    for (final e in errors) {
      stderr.writeln(' [FAIL] $e');
    }
    exit(1);
  }

  stdout.writeln('\n[PASS] All Pre-Release Quality & Store Compliance checks passed!');
}

void _verifyTextFile({
  required String path,
  required int maxChars,
  required String label,
  required List<String> errors,
}) {
  final file = File(path);
  if (!file.existsSync()) {
    errors.add('Missing metadata file: $path');
    return;
  }
  final text = file.readAsStringSync().trim();
  if (text.isEmpty) {
    errors.add('Empty metadata file: $path');
    return;
  }
  if (text.runes.length > maxChars) {
    errors.add(
      '$label exceeds limit (${text.runes.length} > $maxChars chars)',
    );
  }
}

bool _verifyPngDimensions({
  required String path,
  required int expectedWidth,
  required int expectedHeight,
  required List<String> errors,
}) {
  final file = File(path);
  if (!file.existsSync()) {
    errors.add('Missing screenshot PNG: $path');
    return false;
  }
  final bytes = file.readAsBytesSync();
  if (bytes.length < 24 ||
      bytes[0] != 0x89 ||
      bytes[1] != 0x50 ||
      bytes[2] != 0x4E ||
      bytes[3] != 0x47) {
    errors.add('Invalid PNG header in $path');
    return false;
  }
  final width =
      (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
  final height =
      (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
  if (width != expectedWidth || height != expectedHeight) {
    errors.add(
      'Screenshot dimension mismatch in $path: expected ${expectedWidth}x$expectedHeight, got ${width}x$height',
    );
    return false;
  }
  return true;
}

