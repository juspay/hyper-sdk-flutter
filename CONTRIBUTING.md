# Contributing to Visa Infinite Access SDK for Flutter

The example application uses the local Flutter package through `visa_infinite_access_sdk_flutter: path: ../`. See the [main README](README.md) for the complete VIA integration guide.

## Configure the example

Fetch dependencies from the `example/` directory:

```sh
flutter pub get
```

Use test identifiers and auth data supplied for your sandbox environment. Do not commit real credentials, auth codes, private keys, cardholder PII, or card data.

### Android

The example's root `android/build.gradle` declares only the `com.visa:visainfiniteaccess.plugin:0.0.1` classpath. Its `android/app/build.gradle` applies `visainfiniteaccess.plugin` and configures the client directly through `visaInfiniteAccessPlugin`; no root `ext.clientId` is used.

Change the test client in `example/android/app/build.gradle`:

```groovy
visaInfiniteAccessPlugin {
    clientId = "viaglobal"
}
```

The application owns the VIA Assets Plugin setup. The Flutter SDK supplies only the HyperSDK dependencies and does not apply the VIA plugin.

### iOS

Update the client key in `example/ios/VisaInfiniteAccessConfig.json`:

```json
{
  "clientConfigs": {
    "viaglobal": {}
  }
}
```

The example uses CocoaPods. After changing the client, regenerate dependencies and VIA assets:

```sh
cd ios
pod install
cd ..
```

The example targets iOS 15 for the installed Xcode 27 toolchain. The Flutter package itself supports iOS 13 and later.

## Run the example

From `example/`:

```sh
flutter run
```

For an unsigned iOS device-build check, run:

```sh
flutter build ios --no-codesign
```

Keep changes focused and run `flutter analyze` from the repository root before submitting changes.
