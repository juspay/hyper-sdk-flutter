/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

// Syncs the HyperSDK version used by Swift Package Manager with the app's
// `hyper_sdk_ios_version` in pubspec.yaml.
//
// Run from the app's root folder after changing hyper_sdk_ios_version:
//
//   dart run hypersdkflutter:sync_hypersdk_version
//
// It rewrites the `var hyperSdkVersion` line in this plugin's
// ios/hypersdkflutter/Package.swift. SwiftPM caches manifests by their
// contents, so changing that line makes SwiftPM evaluate the manifest again
// and resolve the new version.

import 'dart:io';
import 'dart:isolate';

// Same rules as ios/hypersdkflutter/Package.swift.
final _overridePattern = RegExp(r'''^hyper_sdk_ios_version:[ \t]*["']?([^"'#\s]*)''', multiLine: true);
final _validVersionPattern = RegExp(r'^\d+\.\d+\.\d+((\.|-rc\.)\d+)?$');
final _defaultVersionPattern = RegExp(r'let defaultHyperSdkVersion = "([^"]+)"');
final _versionLinePattern = RegExp(r'^var hyperSdkVersion = .*$', multiLine: true);

Future<void> main(List<String> args) async {
  if (args.isNotEmpty) {
    _fail('Unknown argument: ${args.first}\nUsage: dart run hypersdkflutter:sync_hypersdk_version', exitCode: 64);
  }

  final appPubspec = File('pubspec.yaml');
  if (!appPubspec.existsSync()) {
    _fail('pubspec.yaml not found in ${Directory.current.path}. Run this command from your app\'s root folder.');
  }

  final libUri = await Isolate.resolvePackageUri(Uri.parse('package:hypersdkflutter/hypersdkflutter.dart'));
  if (libUri == null) {
    _fail('Could not locate the hypersdkflutter package. Run `flutter pub get` first.');
  }
  final packageSwift = File.fromUri(libUri.resolve('../ios/hypersdkflutter/Package.swift'));
  if (!packageSwift.existsSync()) {
    _fail('Package.swift not found at ${packageSwift.path}.');
  }

  final manifest = packageSwift.readAsStringSync();
  final defaultVersion = _defaultVersionPattern.firstMatch(manifest)?.group(1);
  if (defaultVersion == null || !_versionLinePattern.hasMatch(manifest)) {
    _fail('Unexpected contents in ${packageSwift.path}.');
  }

  var expectedVersion = defaultVersion;
  final overrideValue = _overridePattern.firstMatch(appPubspec.readAsStringSync())?.group(1);
  if (overrideValue != null) {
    if (!_validVersionPattern.hasMatch(overrideValue)) {
      _fail("hyper_sdk_ios_version '$overrideValue' in pubspec.yaml is not a valid HyperSDK version. Use X.Y.Z, X.Y.Z.N or X.Y.Z-rc.N, e.g. 2.2.9.7.");
    }
    final overrideVersion = overrideValue.replaceAll('-rc.', '.');
    if (_compareVersions(overrideVersion, defaultVersion) > 0) {
      expectedVersion = overrideVersion;
    }
  }

  final versionLine = expectedVersion == defaultVersion
      ? 'var hyperSdkVersion = defaultHyperSdkVersion'
      : 'var hyperSdkVersion = "$expectedVersion"';
  final updatedManifest = manifest.replaceFirst(_versionLinePattern, versionLine);
  if (updatedManifest != manifest) {
    packageSwift.writeAsStringSync(updatedManifest);
    stdout.writeln('[HyperSDK] Set the Swift Package Manager HyperSDK version to $expectedVersion in ${packageSwift.path}');
  } else {
    stdout.writeln('[HyperSDK] Swift Package Manager HyperSDK version is already $expectedVersion');
  }
}

int _compareVersions(String a, String b) {
  List<int> parts(String version) => version.split('.').map(int.parse).toList();
  final partsA = parts(a), partsB = parts(b);
  for (var i = 0; i < partsA.length || i < partsB.length; i++) {
    final partA = i < partsA.length ? partsA[i] : 0;
    final partB = i < partsB.length ? partsB[i] : 0;
    if (partA != partB) return partA - partB;
  }
  return 0;
}

Never _fail(String message, {int exitCode = 1}) {
  stderr.writeln('error: [HyperSDK] $message');
  exit(exitCode);
}
