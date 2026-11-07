import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

const String kKeyId = '3U5GRBXLAR';
const String kIssuerId = '47e0206d-5840-4dbb-b8d7-80f19523322d';
const String kKeyPath = 'AuthKey_3U5GRBXLAR.p8';
const String kBundleId = 'com.goalverse.footballsos';
const String kProfileName = 'Goalverse Football SOS AppStore';

String _base64UrlNoPad(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

Uint8List _derSignatureToRaw64(Uint8List der) {
  if (der.length < 8 || der[0] != 0x30) {
    throw FormatException('Invalid DER ECDSA signature header');
  }
  var offset = 2;
  if (der[1] & 0x80 != 0) {
    offset = 2 + (der[1] & 0x7f);
  }
  if (der[offset] != 0x02) {
    throw FormatException('Expected INTEGER for R');
  }
  final rLen = der[offset + 1];
  final rBytes = der.sublist(offset + 2, offset + 2 + rLen);
  offset += 2 + rLen;

  if (der[offset] != 0x02) {
    throw FormatException('Expected INTEGER for S');
  }
  final sLen = der[offset + 1];
  final sBytes = der.sublist(offset + 2, offset + 2 + sLen);

  final out = Uint8List(64);
  _copyBigIntBytes32(rBytes, out, 0);
  _copyBigIntBytes32(sBytes, out, 32);
  return out;
}

void _copyBigIntBytes32(Uint8List src, Uint8List dst, int dstOffset) {
  var start = 0;
  while (start < src.length && src[start] == 0 && (src.length - start) > 32) {
    start++;
  }
  final trimmed = src.sublist(start);
  if (trimmed.length > 32) {
    throw FormatException('ECDSA integer exceeds 32 bytes: ${trimmed.length}');
  }
  final pad = 32 - trimmed.length;
  for (var i = 0; i < trimmed.length; i++) {
    dst[dstOffset + pad + i] = trimmed[i];
  }
}

String generateAscJwt() {
  final keyFile = File(kKeyPath);
  if (!keyFile.existsSync()) {
    throw StateError('Missing private key file: $kKeyPath');
  }

  final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final header = {'alg': 'ES256', 'kid': kKeyId, 'typ': 'JWT'};
  final payload = {
    'iss': kIssuerId,
    'iat': nowSec - 30,
    'exp': nowSec + 1100,
    'aud': 'appstoreconnect-v1',
  };

  final signingInput =
      '${_base64UrlNoPad(utf8.encode(jsonEncode(header)))}.${_base64UrlNoPad(utf8.encode(jsonEncode(payload)))}';

  final tmpInput = File('${Directory.systemTemp.path}/asc_jwt_input.txt');
  tmpInput.writeAsStringSync(signingInput, flush: true);

  final res = Process.runSync('openssl', [
    'dgst',
    '-sha256',
    '-sign',
    keyFile.path,
    tmpInput.path,
  ], stdoutEncoding: null);

  if (res.exitCode != 0) {
    throw StateError('openssl dgst failed: ${res.stderr}');
  }

  final derBytes = Uint8List.fromList(res.stdout as List<int>);
  final raw64 = _derSignatureToRaw64(derBytes);
  return '$signingInput.${_base64UrlNoPad(raw64)}';
}

Future<Map<String, dynamic>> ascRequest(
  String method,
  String url,
  String jwt, {
  Map<String, dynamic>? body,
}) async {
  final client = HttpClient();
  try {
    final req = await client.openUrl(method, Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $jwt');
    req.headers.set('Content-Type', 'application/json');
    if (body != null) {
      req.add(utf8.encode(jsonEncode(body)));
    }
    final resp = await req.close();
    final respBody = await resp.transform(utf8.decoder).join();
    final decoded = respBody.isNotEmpty
        ? jsonDecode(respBody) as Map<String, dynamic>
        : <String, dynamic>{};
    decoded['_statusCode'] = resp.statusCode;
    return decoded;
  } finally {
    client.close();
  }
}

Future<void> _uploadBinaryChunk({
  required String method,
  required String url,
  required List<dynamic> requestHeaders,
  required Uint8List bytes,
}) async {
  final client = HttpClient();
  try {
    final req = await client.openUrl(method, Uri.parse(url));
    for (final h in requestHeaders) {
      final hm = h as Map<String, dynamic>;
      req.headers.set(hm['name'] as String, hm['value'] as String);
    }
    req.contentLength = bytes.length;
    req.add(bytes);
    final resp = await req.close();
    await resp.drain<void>();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError('Chunk upload failed with HTTP ${resp.statusCode}');
    }
  } finally {
    client.close();
  }
}

Future<void> _uploadScreenshotsForLocalization({
  required String jwt,
  required String localizationId,
  required String locale,
}) async {
  final screenshotDir = Directory('ios/fastlane/screenshots/$locale');
  if (!screenshotDir.existsSync()) return;

  final pngFiles = screenshotDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (pngFiles.isEmpty) return;

  // 1. Find or create APP_IPHONE_67 screenshot set
  final setsResp = await ascRequest(
    'GET',
    'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/$localizationId/appScreenshotSets',
    jwt,
  );
  String? setId;
  for (final s in (setsResp['data'] as List<dynamic>? ?? [])) {
    final sm = s as Map<String, dynamic>;
    final dtype = (sm['attributes'] as Map)['screenshotDisplayType'] as String?;
    if (dtype == 'APP_IPHONE_67') {
      setId = sm['id'] as String;
      break;
    }
  }

  if (setId == null) {
    final createSet = await ascRequest(
      'POST',
      'https://api.appstoreconnect.apple.com/v1/appScreenshotSets',
      jwt,
      body: {
        'data': {
          'type': 'appScreenshotSets',
          'attributes': {'screenshotDisplayType': 'APP_IPHONE_67'},
          'relationships': {
            'appStoreVersionLocalization': {
              'data': {
                'type': 'appStoreVersionLocalizations',
                'id': localizationId,
              },
            },
          },
        },
      },
    );
    if (createSet['data'] != null) {
      setId = (createSet['data'] as Map)['id'] as String;
    }
  }
  if (setId == null) return;

  // Clear existing screenshots in set to avoid duplicates
  final existingShots = await ascRequest(
    'GET',
    'https://api.appstoreconnect.apple.com/v1/appScreenshotSets/$setId/appScreenshots',
    jwt,
  );
  for (final shot in (existingShots['data'] as List<dynamic>? ?? [])) {
    final shotId = (shot as Map)['id'] as String;
    await ascRequest(
      'DELETE',
      'https://api.appstoreconnect.apple.com/v1/appScreenshots/$shotId',
      jwt,
    );
  }

  for (final png in pngFiles) {
    final bytes = png.readAsBytesSync();
    final fileName = png.uri.pathSegments.last;
    final md5Hex = md5.convert(bytes).toString();

    final reserveResp = await ascRequest(
      'POST',
      'https://api.appstoreconnect.apple.com/v1/appScreenshots',
      jwt,
      body: {
        'data': {
          'type': 'appScreenshots',
          'attributes': {
            'fileSize': bytes.length,
            'fileName': fileName,
          },
          'relationships': {
            'appScreenshotSet': {
              'data': {'type': 'appScreenshotSets', 'id': setId},
            },
          },
        },
      },
    );

    final shotData = reserveResp['data'] as Map<String, dynamic>?;
    if (shotData == null) continue;
    final shotId = shotData['id'] as String;
    final ops =
        (shotData['attributes'] as Map<String, dynamic>)['uploadOperations']
            as List<dynamic>? ??
        [];

    for (final op in ops) {
      final opMap = op as Map<String, dynamic>;
      final offset = opMap['offset'] as int;
      final length = opMap['length'] as int;
      final chunk = Uint8List.sublistView(bytes, offset, offset + length);
      await _uploadBinaryChunk(
        method: opMap['method'] as String,
        url: opMap['url'] as String,
        requestHeaders: opMap['requestHeaders'] as List<dynamic>,
        bytes: chunk,
      );
    }

    await ascRequest(
      'PATCH',
      'https://api.appstoreconnect.apple.com/v1/appScreenshots/$shotId',
      jwt,
      body: {
        'data': {
          'type': 'appScreenshots',
          'id': shotId,
          'attributes': {
            'uploaded': true,
            'sourceFileChecksum': md5Hex,
          },
        },
      },
    );
  }
  stdout.writeln(
    '[OK] Uploaded ${pngFiles.length} iOS 6.7" screenshots for [$locale]',
  );
}

Future<void> main(List<String> args) async {
  stdout.writeln('=== App Store Connect API Setup & Full Store Sync ===');
  final jwt = generateAscJwt();
  stdout.writeln('[OK] Generated ES256 JWT for Key ID: $kKeyId');

  // 1. Check / Register Bundle ID com.goalverse.footballsos
  final bundleResp = await ascRequest(
    'GET',
    'https://api.appstoreconnect.apple.com/v1/bundleIds?filter[identifier]=$kBundleId',
    jwt,
  );
  final existingBundles = (bundleResp['data'] as List<dynamic>? ?? []);
  String bundleResourceId;
  if (existingBundles.isEmpty) {
    final createResp = await ascRequest(
      'POST',
      'https://api.appstoreconnect.apple.com/v1/bundleIds',
      jwt,
      body: {
        'data': {
          'type': 'bundleIds',
          'attributes': {
            'identifier': kBundleId,
            'name': 'Goalverse Football SOS',
            'platform': 'IOS',
          },
        },
      },
    );
    bundleResourceId = (createResp['data'] as Map)['id'] as String;
    stdout.writeln(
      '[OK] Registered Bundle ID "$kBundleId" (ID: $bundleResourceId)',
    );
  } else {
    bundleResourceId = (existingBundles.first as Map)['id'] as String;
    stdout.writeln(
      '[OK] Bundle ID "$kBundleId" already registered (ID: $bundleResourceId)',
    );
  }

  // 2. Check if App record exists in App Store Connect
  final appsResp = await ascRequest(
    'GET',
    'https://api.appstoreconnect.apple.com/v1/apps?filter[bundleId]=$kBundleId',
    jwt,
  );
  final matchingApps = (appsResp['data'] as List<dynamic>? ?? []);
  if (matchingApps.isEmpty) {
    stdout.writeln(
      '\n[WAITING FOR 1-CLICK APP CREATION IN APP STORE CONNECT]:\n'
      '  1. Open https://appstoreconnect.apple.com/apps\n'
      '  2. Click "+" -> "New App"\n'
      '  3. Select iOS, Name: "Goalverse: Football SOS", Primary Language: Turkish, Bundle ID: "com.goalverse.footballsos", SKU: "goalverse-footballsos-01"\n'
      '  4. Run ./scripts/upload_ios_testflight.sh to automatically push the IPA, 6 languages of metadata, and 48 screenshots!',
    );
    return;
  }

  final appId = (matchingApps.first as Map)['id'] as String;
  stdout.writeln('\n[OK] Found App Store Connect App ID: $appId for $kBundleId!');

  // 3. Sync App Info Localizations (Name, Subtitle, Privacy Policy URL) + Categories + Age Rating
  final appInfosResp = await ascRequest(
    'GET',
    'https://api.appstoreconnect.apple.com/v1/apps/$appId/appInfos',
    jwt,
  );
  final appInfos = (appInfosResp['data'] as List<dynamic>? ?? []);
  if (appInfos.isNotEmpty) {
    final appInfoId = (appInfos.first as Map)['id'] as String;

    // 3a. Set App Categories (Games -> Trivia / Sports)
    final catResp = await ascRequest(
      'PATCH',
      'https://api.appstoreconnect.apple.com/v1/appInfos/$appInfoId',
      jwt,
      body: {
        'data': {
          'type': 'appInfos',
          'id': appInfoId,
          'relationships': {
            'primaryCategory': {
              'data': {'type': 'appCategories', 'id': 'GAMES'},
            },
            'primarySubcategoryOne': {
              'data': {'type': 'appCategories', 'id': 'GAMES_TRIVIA'},
            },
            'primarySubcategoryTwo': {
              'data': {'type': 'appCategories', 'id': 'GAMES_SPORTS'},
            },
          },
        },
      },
    );
    stdout.writeln('[OK] Set App Store Categories (GAMES / GAMES_TRIVIA / GAMES_SPORTS) -> HTTP ${catResp["_statusCode"]}');

    // 3b. Complete Age Rating Declaration (4+)
    final ageResp = await ascRequest(
      'GET',
      'https://api.appstoreconnect.apple.com/v1/appInfos/$appInfoId/ageRatingDeclaration',
      jwt,
    );
    final ageId = (ageResp['data'] as Map?)?['id'] as String?;
    if (ageId != null) {
      final patchAge = await ascRequest(
        'PATCH',
        'https://api.appstoreconnect.apple.com/v1/ageRatingDeclarations/$ageId',
        jwt,
        body: {
          'data': {
            'type': 'ageRatingDeclarations',
            'id': ageId,
            'attributes': {
              'alcoholTobaccoOrDrugUseOrReferences': 'NONE',
              'contests': 'NONE',
              'gambling': false,
              'gamblingSimulated': 'NONE',
              'horrorOrFearThemes': 'NONE',
              'matureOrSuggestiveThemes': 'NONE',
              'medicalOrTreatmentInformation': 'NONE',
              'profanityOrCrudeHumor': 'NONE',
              'sexualContentGraphicAndNudity': 'NONE',
              'sexualContentOrNudity': 'NONE',
              'violenceCartoonOrFantasy': 'NONE',
              'violenceRealistic': 'NONE',
              'violenceRealisticProlongedGraphicOrSadistic': 'NONE',
              'unrestrictedWebAccess': false,
              'lootBox': false,
            },
          },
        },
      );
      stdout.writeln('[OK] Completed Age Rating Declaration (4+) -> HTTP ${patchAge["_statusCode"]}');
    }

    final infoLocsResp = await ascRequest(
      'GET',
      'https://api.appstoreconnect.apple.com/v1/appInfos/$appInfoId/appInfoLocalizations',
      jwt,
    );
    final existingInfoLocs = <String, String>{};
    for (final loc in (infoLocsResp['data'] as List<dynamic>? ?? [])) {
      final m = loc as Map;
      final localeCode = (m['attributes'] as Map)['locale'] as String;
      existingInfoLocs[localeCode] = m['id'] as String;
    }

    const iosLocales = ['en-GB', 'tr', 'en-US', 'es-ES', 'fr-FR', 'de-DE', 'it'];
    for (final locale in iosLocales) {
      final sourceLocale = locale == 'en-GB' ? 'en-US' : locale;
      final dir = Directory('ios/fastlane/metadata/$sourceLocale');
      if (!dir.existsSync()) continue;
      final name = File('${dir.path}/name.txt').readAsStringSync().trim();
      final subtitle = File('${dir.path}/subtitle.txt').readAsStringSync().trim();
      final privacyUrl = File('${dir.path}/privacy_url.txt').readAsStringSync().trim();

      if (existingInfoLocs.containsKey(locale)) {
        final locId = existingInfoLocs[locale]!;
        await ascRequest(
          'PATCH',
          'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/$locId',
          jwt,
          body: {
            'data': {
              'type': 'appInfoLocalizations',
              'id': locId,
              'attributes': {
                'name': name,
                'subtitle': subtitle,
                'privacyPolicyUrl': privacyUrl,
              },
            },
          },
        );
      } else {
        await ascRequest(
          'POST',
          'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations',
          jwt,
          body: {
            'data': {
              'type': 'appInfoLocalizations',
              'attributes': {
                'locale': locale,
                'name': name,
                'subtitle': subtitle,
                'privacyPolicyUrl': privacyUrl,
              },
              'relationships': {
                'appInfo': {
                  'data': {'type': 'appInfos', 'id': appInfoId},
                },
              },
            },
          },
        );
      }
      stdout.writeln('[OK] Synced App Info (Name, Subtitle, Privacy URL) [$locale]');
    }
  }

  // 4. Sync 7-Language App Store Version Localizations + Real In-App Screenshots + Build + Review Info
  final versionsResp = await ascRequest(
    'GET',
    'https://api.appstoreconnect.apple.com/v1/apps/$appId/appStoreVersions?filter[platform]=IOS',
    jwt,
  );
  final versions = (versionsResp['data'] as List<dynamic>? ?? []);
  if (versions.isNotEmpty) {
    final versionId = (versions.first as Map)['id'] as String;

    // 4a. Update Version String, Copyright, and Release Type
    final patchVer = await ascRequest(
      'PATCH',
      'https://api.appstoreconnect.apple.com/v1/appStoreVersions/$versionId',
      jwt,
      body: {
        'data': {
          'type': 'appStoreVersions',
          'id': versionId,
          'attributes': {
            'versionString': '1.1.0',
            'copyright': '2026 Goalverse',
            'releaseType': 'AFTER_APPROVAL',
          },
        },
      },
    );
    stdout.writeln('[OK] Updated App Store Version (1.1.0, Copyright) -> HTTP ${patchVer["_statusCode"]}');

    // 4b. Attach latest processed TestFlight Build to this App Store Version
    final buildsResp = await ascRequest(
      'GET',
      'https://api.appstoreconnect.apple.com/v1/builds?filter[app]=$appId&limit=5',
      jwt,
    );
    final builds = (buildsResp['data'] as List<dynamic>? ?? []);
    if (builds.isNotEmpty) {
      final latestBuildId = (builds.first as Map)['id'] as String;
      final attachBuild = await ascRequest(
        'PATCH',
        'https://api.appstoreconnect.apple.com/v1/appStoreVersions/$versionId/relationships/build',
        jwt,
        body: {
          'data': {'type': 'builds', 'id': latestBuildId},
        },
      );
      stdout.writeln('[OK] Attached TestFlight Build ($latestBuildId) to App Store Version -> HTTP ${attachBuild["_statusCode"]}');
    }

    // 4c. Set App Store Review Details (Contact Info & No Demo Account Required)
    final existingRev = await ascRequest(
      'GET',
      'https://api.appstoreconnect.apple.com/v1/appStoreVersions/$versionId/appStoreReviewDetail',
      jwt,
    );
    final existingRevId = (existingRev['data'] as Map?)?['id'] as String?;
    final reviewAttrs = {
      'contactFirstName': 'Goalverse',
      'contactLastName': 'Support',
      'contactEmail': 'support@goalverse.app',
      'contactPhone': '+905551234567',
      'demoAccountRequired': false,
      'notes':
          'Goalverse: Football SOS can be played immediately in Guest Mode, Solo vs AI, Local 2-Player Duel, or Daily Challenge without requiring any login credentials.',
    };
    if (existingRevId != null) {
      final patchRev = await ascRequest(
        'PATCH',
        'https://api.appstoreconnect.apple.com/v1/appStoreReviewDetails/$existingRevId',
        jwt,
        body: {
          'data': {
            'type': 'appStoreReviewDetails',
            'id': existingRevId,
            'attributes': reviewAttrs,
          },
        },
      );
      stdout.writeln('[OK] Updated App Review Details -> HTTP ${patchRev["_statusCode"]}');
    } else {
      final postRev = await ascRequest(
        'POST',
        'https://api.appstoreconnect.apple.com/v1/appStoreReviewDetails',
        jwt,
        body: {
          'data': {
            'type': 'appStoreReviewDetails',
            'attributes': reviewAttrs,
            'relationships': {
              'appStoreVersion': {
                'data': {'type': 'appStoreVersions', 'id': versionId},
              },
            },
          },
        },
      );
      stdout.writeln('[OK] Created App Review Details -> HTTP ${postRev["_statusCode"]}');
    }

    final locResp = await ascRequest(
      'GET',
      'https://api.appstoreconnect.apple.com/v1/appStoreVersions/$versionId/appStoreVersionLocalizations',
      jwt,
    );
    final existingLocs = <String, String>{};
    for (final loc in (locResp['data'] as List<dynamic>? ?? [])) {
      final m = loc as Map;
      final localeCode = (m['attributes'] as Map)['locale'] as String;
      existingLocs[localeCode] = m['id'] as String;
    }

    const iosLocales = ['en-GB', 'tr', 'en-US', 'es-ES', 'fr-FR', 'de-DE', 'it'];
    for (final locale in iosLocales) {
      final sourceLocale = locale == 'en-GB' ? 'en-US' : locale;
      final dir = Directory('ios/fastlane/metadata/$sourceLocale');
      if (!dir.existsSync()) continue;
      final description = File('${dir.path}/description.txt').readAsStringSync().trim();
      final keywords = File('${dir.path}/keywords.txt').readAsStringSync().trim();
      final promo = File('${dir.path}/promotional_text.txt').readAsStringSync().trim();
      final supportUrl = File('${dir.path}/support_url.txt').readAsStringSync().trim();
      final marketingUrl = File('${dir.path}/marketing_url.txt').readAsStringSync().trim();

      String? locId = existingLocs[locale];
      if (locId != null) {
        await ascRequest(
          'PATCH',
          'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/$locId',
          jwt,
          body: {
            'data': {
              'type': 'appStoreVersionLocalizations',
              'id': locId,
              'attributes': {
                'description': description,
                'keywords': keywords,
                'promotionalText': promo,
                'supportUrl': supportUrl,
                'marketingUrl': marketingUrl,
              },
            },
          },
        );
        stdout.writeln('[OK] Updated App Store Version localization [$locale]');
      } else {
        final created = await ascRequest(
          'POST',
          'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations',
          jwt,
          body: {
            'data': {
              'type': 'appStoreVersionLocalizations',
              'attributes': {
                'locale': locale,
                'description': description,
                'keywords': keywords,
                'promotionalText': promo,
                'supportUrl': supportUrl,
                'marketingUrl': marketingUrl,
              },
              'relationships': {
                'appStoreVersion': {
                  'data': {'type': 'appStoreVersions', 'id': versionId},
                },
              },
            },
          },
        );
        locId = (created['data'] as Map?)?['id'] as String?;
        stdout.writeln('[OK] Created App Store Version localization [$locale]');
      }

      if (locId != null) {
        await _uploadScreenshotsForLocalization(
          jwt: jwt,
          localizationId: locId,
          locale: locale,
        );
      }
    }
  }
}
