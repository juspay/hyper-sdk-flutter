// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Default HyperSDK version of this plugin release, in CocoaPods format (X.Y.Z or X.Y.Z.N).
let defaultHyperSdkVersion = "2.2.9"

// The base HyperSDK version for the app. The app can raise it by
// setting `hyper_sdk_ios_version` in its pubspec.yaml and running
// `dart run hypersdkflutter:sync_hypersdk_version`, which rewrites this line.
let hyperSdkVersion = defaultHyperSdkVersion

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
