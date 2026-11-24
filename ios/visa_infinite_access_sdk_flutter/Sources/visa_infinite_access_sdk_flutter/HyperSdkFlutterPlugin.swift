/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Flutter

// Plugin entry point registered by GeneratedPluginRegistrant (pluginClass in pubspec.yaml).
// Replaces the former Objective-C HyperSdkFlutterPlugin class, since Swift packages can't
// mix Objective-C and Swift sources in one target.
@objc(HyperSdkFlutterPlugin)
public class HyperSdkFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftHyperSdkFlutterPlugin.register(with: registrar)
    }
}
