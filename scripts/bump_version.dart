import 'dart:io';

/// Automatic version and build number manager for Goalverse: Football SOS.
///
/// Usage:
///   dart run scripts/bump_version.dart --bump-build
///   dart run scripts/bump_version.dart --bump-patch
///   dart run scripts/bump_version.dart --bump-minor
///   dart run scripts/bump_version.dart --bump-major
///   dart run scripts/bump_version.dart --set-build=42
void main(List<String> args) {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found in current directory.');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    multiLine: true,
  );
  final match = versionRegex.firstMatch(content);
  if (match == null) {
    stderr.writeln('Error: Could not parse version: X.Y.Z+B in pubspec.yaml.');
    exit(1);
  }

  var major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!);
  var build = int.parse(match.group(4)!);

  final envBuildNumber =
      Platform.environment['BUILD_NUMBER'] ??
      Platform.environment['CM_BUILD_NUMBER'] ??
      Platform.environment['PROJECT_BUILD_NUMBER'];

  var modified = false;

  for (final arg in args) {
    if (arg == '--bump-major') {
      major += 1;
      minor = 0;
      patch = 0;
      build += 1;
      modified = true;
    } else if (arg == '--bump-minor') {
      minor += 1;
      patch = 0;
      build += 1;
      modified = true;
    } else if (arg == '--bump-patch') {
      patch += 1;
      build += 1;
      modified = true;
    } else if (arg == '--bump-build') {
      build += 1;
      modified = true;
    } else if (arg.startsWith('--set-build=')) {
      final parsed = int.tryParse(arg.split('=').last);
      if (parsed == null || parsed <= 0) {
        stderr.writeln('Invalid --set-build value: $arg');
        exit(1);
      }
      build = parsed;
      modified = true;
    } else if (arg.startsWith('--set-version=')) {
      final parts = arg.split('=').last.split('.');
      if (parts.length != 3) {
        stderr.writeln('Invalid --set-version value (expected X.Y.Z): $arg');
        exit(1);
      }
      major = int.parse(parts[0]);
      minor = int.parse(parts[1]);
      patch = int.parse(parts[2]);
      modified = true;
    }
  }

  if (!modified && envBuildNumber != null) {
    final parsedEnvBuild = int.tryParse(envBuildNumber);
    if (parsedEnvBuild != null && parsedEnvBuild > build) {
      build = parsedEnvBuild;
      modified = true;
    }
  }

  if (!modified && args.isEmpty) {
    build += 1;
    modified = true;
  }

  final newVersionString = '$major.$minor.$patch+$build';
  final updatedContent = content.replaceFirst(
    versionRegex,
    'version: $newVersionString',
  );
  pubspecFile.writeAsStringSync(updatedContent);

  // Sync Google Play changelog file <build>.txt for all 6 locales if default.txt exists
  const androidLocales = [
    'tr-TR',
    'en-US',
    'es-ES',
    'fr-FR',
    'de-DE',
    'it-IT',
  ];
  for (final locale in androidLocales) {
    final changelogDir = Directory(
      'android/fastlane/metadata/android/$locale/changelogs',
    );
    final defaultFile = File('${changelogDir.path}/default.txt');
    if (defaultFile.existsSync()) {
      final buildFile = File('${changelogDir.path}/$build.txt');
      buildFile.writeAsStringSync(defaultFile.readAsStringSync());
    }
  }

  stdout.writeln('Updated version to $newVersionString');
}

