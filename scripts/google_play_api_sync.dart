import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const String kPackageName = 'com.goalverse.footballsos';
const String kServiceAccountPath =
    'android/fastlane/google-play-service-account.json';

String _base64UrlNoPad(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

Future<String> _fetchGoogleAccessToken(File saFile) async {
  final saJson = jsonDecode(saFile.readAsStringSync()) as Map<String, dynamic>;
  final clientEmail = saJson['client_email'] as String;
  final privateKeyPem = saJson['private_key'] as String;

  final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final header = {'alg': 'RS256', 'typ': 'JWT'};
  final claim = {
    'iss': clientEmail,
    'scope': 'https://www.googleapis.com/auth/androidpublisher',
    'aud': 'https://oauth2.googleapis.com/token',
    'iat': nowSec - 30,
    'exp': nowSec + 3500,
  };

  final signingInput =
      '${_base64UrlNoPad(utf8.encode(jsonEncode(header)))}.${_base64UrlNoPad(utf8.encode(jsonEncode(claim)))}';

  final tmpKey = File('${Directory.systemTemp.path}/gp_sa_key.pem');
  final tmpIn = File('${Directory.systemTemp.path}/gp_jwt_in.txt');
  tmpKey.writeAsStringSync(privateKeyPem, flush: true);
  tmpIn.writeAsStringSync(signingInput, flush: true);

  final signRes = Process.runSync('openssl', [
    'dgst',
    '-sha256',
    '-sign',
    tmpKey.path,
    tmpIn.path,
  ], stdoutEncoding: null);
  tmpKey.deleteSync();
  tmpIn.deleteSync();

  if (signRes.exitCode != 0) {
    throw StateError('Failed to sign Google JWT: ${signRes.stderr}');
  }

  final sigBytes = Uint8List.fromList(signRes.stdout as List<int>);
  final assertion = '$signingInput.${_base64UrlNoPad(sigBytes)}';

  final client = HttpClient();
  try {
    final req = await client.postUrl(
      Uri.parse('https://oauth2.googleapis.com/token'),
    );
    req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
    final body =
        'grant_type=${Uri.encodeQueryComponent("urn:ietf:params:oauth:grant-type:jwt-bearer")}&assertion=${Uri.encodeQueryComponent(assertion)}';
    req.add(utf8.encode(body));
    final resp = await req.close();
    final respText = await resp.transform(utf8.decoder).join();
    final decoded = jsonDecode(respText) as Map<String, dynamic>;
    if (decoded['access_token'] == null) {
      throw StateError('Google OAuth token exchange failed: $respText');
    }
    return decoded['access_token'] as String;
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> _gpRequest(
  String method,
  String url,
  String token, {
  Map<String, dynamic>? jsonBody,
  Uint8List? binaryBody,
  String? contentType,
}) async {
  final client = HttpClient();
  try {
    final req = await client.openUrl(method, Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $token');
    if (binaryBody != null) {
      req.headers.set('Content-Type', contentType ?? 'application/octet-stream');
      req.contentLength = binaryBody.length;
      req.add(binaryBody);
    } else if (jsonBody != null) {
      final bytes = utf8.encode(jsonEncode(jsonBody));
      req.headers.set('Content-Type', 'application/json');
      req.contentLength = bytes.length;
      req.add(bytes);
    } else if (method == 'POST' || method == 'PUT') {
      req.contentLength = 0;
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

Future<void> main(List<String> args) async {
  final saFile = File(kServiceAccountPath);
  if (!saFile.existsSync()) {
    stderr.writeln('Missing $kServiceAccountPath');
    exit(1);
  }

  stdout.writeln('=== Google Play Developer API Sync ($kPackageName) ===');
  final token = await _fetchGoogleAccessToken(saFile);
  stdout.writeln('[OK] Obtained Google Play AndroidPublisher OAuth2 token.');

  const baseApi =
      'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$kPackageName';
  const uploadBaseApi =
      'https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/$kPackageName';

  const allLocales = ['en-GB', 'tr-TR', 'en-US', 'es-ES', 'fr-FR', 'de-DE', 'it-IT'];
  // Optional: pass locales as CLI args to sync only a subset (e.g. after a network failure)
  final locales = args.isEmpty ? allLocales : args;

  for (final locale in locales) {
    final sourceLocale = locale == 'en-GB' ? 'en-US' : locale;
    final dir = Directory('android/fastlane/metadata/android/$sourceLocale');
    if (!dir.existsSync()) continue;

    final editResp = await _gpRequest('POST', '$baseApi/edits', token, jsonBody: {});
    final editId = editResp['id'] as String;

    final title = File('${dir.path}/title.txt').readAsStringSync().trim();
    final shortDesc = File('${dir.path}/short_description.txt').readAsStringSync().trim();
    final fullDesc = File('${dir.path}/full_description.txt').readAsStringSync().trim();

    final listResp = await _gpRequest(
      'PUT',
      '$baseApi/edits/$editId/listings/$locale',
      token,
      jsonBody: {
        'language': locale,
        'title': title,
        'shortDescription': shortDesc,
        'fullDescription': fullDesc,
      },
    );
    if (listResp['_statusCode'] != 200) {
      stderr.writeln('Listing PUT [$locale] failed: ${jsonEncode(listResp)}');
    }

    final iconFile = File('${dir.path}/images/icon.png');
    if (iconFile.existsSync()) {
      await _gpRequest(
        'DELETE',
        '$baseApi/edits/$editId/listings/$locale/icon',
        token,
      );
      final iconResp = await _gpRequest(
        'POST',
        '$uploadBaseApi/edits/$editId/listings/$locale/icon?uploadType=media',
        token,
        binaryBody: iconFile.readAsBytesSync(),
        contentType: 'image/png',
      );
      if (iconResp['_statusCode'] != 200) {
        stderr.writeln('Icon POST [$locale] failed: ${jsonEncode(iconResp)}');
      }
    }

    final featureFile = File('${dir.path}/images/featureGraphic.png');
    if (featureFile.existsSync()) {
      await _gpRequest(
        'DELETE',
        '$baseApi/edits/$editId/listings/$locale/featureGraphic',
        token,
      );
      final fgResp = await _gpRequest(
        'POST',
        '$uploadBaseApi/edits/$editId/listings/$locale/featureGraphic?uploadType=media',
        token,
        binaryBody: featureFile.readAsBytesSync(),
        contentType: 'image/png',
      );
      if (fgResp['_statusCode'] != 200) {
        stderr.writeln('FeatureGraphic POST [$locale] failed: ${jsonEncode(fgResp)}');
      }
    }

    final shotsDir = Directory('${dir.path}/images/phoneScreenshots');
    if (shotsDir.existsSync()) {
      await _gpRequest(
        'DELETE',
        '$baseApi/edits/$editId/listings/$locale/phoneScreenshots',
        token,
      );
      final pngs = shotsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final png in pngs) {
        final shotResp = await _gpRequest(
          'POST',
          '$uploadBaseApi/edits/$editId/listings/$locale/phoneScreenshots?uploadType=media',
          token,
          binaryBody: png.readAsBytesSync(),
          contentType: 'image/png',
        );
        if (shotResp['_statusCode'] != 200) {
          stderr.writeln('Screenshot POST [$locale] failed: ${jsonEncode(shotResp)}');
        }
      }
    }

    if (locale == 'tr-TR') {
      await _gpRequest(
        'PUT',
        '$baseApi/edits/$editId/details',
        token,
        jsonBody: {
          'defaultLanguage': 'tr-TR',
          'contactEmail': 'support@goalverse.app',
          'contactWebsite': 'https://flutterfootbalquiz.web.app',
        },
      );
    }

    final commitResp = await _gpRequest('POST', '$baseApi/edits/$editId:commit', token);
    stdout.writeln(
      '[$locale] Committed listing + icon + featureGraphic + 8 screenshots -> HTTP ${commitResp["_statusCode"]}',
    );
  }

  // Also update internal track release notes (whatsNew) for versionCode 3 across all locales
  {
    final editResp = await _gpRequest('POST', '$baseApi/edits', token, jsonBody: {});
    final editId = editResp['id'] as String;
    final releaseNotes = <Map<String, String>>[];
    for (final locale in allLocales) {
      final sourceLocale = locale == 'en-GB' ? 'en-US' : locale;
      final clFile = File('android/fastlane/metadata/android/$sourceLocale/changelogs/default.txt');
      if (clFile.existsSync()) {
        releaseNotes.add({
          'language': locale,
          'text': clFile.readAsStringSync().trim(),
        });
      }
    }
    final trackResp = await _gpRequest(
      'PUT',
      '$baseApi/edits/$editId/tracks/internal',
      token,
      jsonBody: {
        'track': 'internal',
        'releases': [
          {
            'name': '3 (1.1.0)',
            'versionCodes': ['3'],
            'status': 'completed',
            'releaseNotes': releaseNotes,
          },
        ],
      },
    );
    final commitTrack = await _gpRequest('POST', '$baseApi/edits/$editId:commit', token);
    stdout.writeln(
      '[Internal Track Release Notes v1.1.0+3] PUT HTTP ${trackResp["_statusCode"]}, Commit HTTP ${commitTrack["_statusCode"]}',
    );
  }
}
