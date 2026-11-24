# Visa Infinite Access Flutter example

This application uses the local `visa_infinite_access_sdk_flutter` package in `../` and provides a host for testing the VIA integration.

## Configure the VIA client

- **Android:** the root `android/build.gradle` declares only the VIA Assets Plugin classpath. `android/app/build.gradle` applies the plugin and sets `clientId` directly inside `visaInfiniteAccessPlugin`; no root `ext.clientId` is needed. Replace `viaglobal` with the client assigned by the VIA team.
- **iOS:** set the client key in `ios/VisaInfiniteAccessConfig.json`:

  ```json
  {
    "clientConfigs": {
      "viaglobal": {}
    }
  }
  ```

The example uses `viaglobal` for iOS asset generation. Replace it only if the VIA team assigns a different client ID.

Use sandbox identifiers and auth data without committing credentials, auth codes, cardholder PII, or card data. See the [main integration guide](../README.md#invoke-the-sdk) for the initiate, login, benefit, logout, and terminate call contracts.

## Run

Fetch dependencies and build-time assets:

```sh
flutter pub get
cd ios
pod install
cd ..
```

Then run the application:

```sh
flutter run
```

For an unsigned iOS device-build check:

```sh
flutter build ios --no-codesign
```

The example disables Swift Package Manager to exercise the CocoaPods integration and targets iOS 15 for the installed Xcode 27 toolchain. The package itself supports iOS 13 and later and also supports Swift Package Manager.

## Dart API

```dart
import 'package:visa_infinite_access_sdk_flutter/visa_infinite_access_sdk_flutter.dart';

final viaSdk = VisaInfiniteAccessSdk();
```
