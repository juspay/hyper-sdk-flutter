// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// Default HyperSDK version of this plugin release, in CocoaPods format (X.Y.Z or X.Y.Z.N).
let defaultHyperSdkVersion = "2.2.9"

// The HyperSDK version for the app, rewritten by `dart run hypersdkflutter:sync_hypersdk_version`.
// SwiftPM caches this manifest by its contents and won't notice pubspec.yaml changes on
// its own, so the command rewrites this line to make SwiftPM evaluate the manifest again.
var hyperSdkVersion = defaultHyperSdkVersion

// Like hypersdkflutter.podspec, the app can raise the HyperSDK version by setting
// `hyper_sdk_ios_version` in its pubspec.yaml, either as the CocoaPods version
// (2.2.9.7) or as the hypersdk-ios tag (2.2.9-rc.7). Flutter links this package into
// <app>/ios/Flutter/ephemeral/Packages/.packages/, so the app root is the part of
// #filePath before /ios/Flutter/ephemeral/. Keep in sync with bin/sync_hypersdk_version.dart.
if let ephemeral = #filePath.range(of: "/ios/Flutter/ephemeral/"),
   let pubspec = try? String(contentsOfFile: #filePath[..<ephemeral.lowerBound] + "/pubspec.yaml", encoding: .utf8) {
    hyperSdkVersion = defaultHyperSdkVersion
    if let keyRegex = try? NSRegularExpression(pattern: #"^hyper_sdk_ios_version:[ \t]*["']?([^"'#\s]*)"#, options: .anchorsMatchLines),
       let keyMatch = keyRegex.firstMatch(in: pubspec, range: NSRange(pubspec.startIndex..., in: pubspec)),
       let valueRange = Range(keyMatch.range(at: 1), in: pubspec) {
        let value = String(pubspec[valueRange])
        guard value.range(of: #"^\d+\.\d+\.\d+((\.|-rc\.)\d+)?$"#, options: .regularExpression) != nil else {
            fatalError("hyper_sdk_ios_version '\(value)' in pubspec.yaml is not a valid HyperSDK version. Use X.Y.Z, X.Y.Z.N or X.Y.Z-rc.N, e.g. 2.2.9.7.")
        }
        let overrideVersion = value.replacingOccurrences(of: "-rc.", with: ".")
        let components = { (version: String) in version.split(separator: ".").map { Int($0)! } + [0] }
        if components(defaultHyperSdkVersion).lexicographicallyPrecedes(components(overrideVersion)) {
            hyperSdkVersion = overrideVersion
        }
    }
}

// hypersdk-ios tags the CocoaPods release X.Y.Z.N as X.Y.Z-rc.N (e.g. 2.2.9.7 -> 2.2.9-rc.7).
let versionComponents = hyperSdkVersion.split(separator: ".")
let hyperSdkTag = versionComponents.count == 4
    ? versionComponents[0..<3].joined(separator: ".") + "-rc." + versionComponents[3]
    : hyperSdkVersion

let package = Package(
    name: "hypersdkflutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "hypersdkflutter", targets: ["hypersdkflutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/juspay/hypersdk-ios.git", exact: Version(hyperSdkTag)!)
    ],
    targets: [
        .target(
            name: "hypersdkflutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "HyperSDK", package: "hypersdk-ios")
            ]
        )
    ]
)
