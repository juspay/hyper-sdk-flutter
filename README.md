# Hyper SDK Flutter

Flutter plugin for HyperSDK which enables payment orchestration via different dynamic modules.

## Flutter Setup

Add flutter plugin dependency in `pubspec.yaml`.
Get dependency from [pub.dev](https://pub.dev/packages/hypersdkflutter/install)

## Android Setup

Add the clientId ext property in root(top) `build.gradle`:

```groovy
buildscript {
    ....
    ext {
        ....
        clientId = "<clientId shared by Juspay team>"
        hyperSDKVersion = "2.1.23"
        ....
    }
    ....
}
```

Optionally, you can also provide an override for base SDK version present in plugin (the newer version among both would be considered).



### Note

**Your application's `MainActivity` should extend `FlutterFragmentActivity` instead of `FlutterActivity`.**

_`HyperSDK` only supports `FragmentActivity`._

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity


class MainActivity: FlutterFragmentActivity() {

}
```



## iOS Setup

Add the following post_install script in the Podfile (`ios/Podfile`)

```sh
post_install do |installer|
  fuse_path = "./Pods/HyperSDK/Fuse.rb"
  clean_assets = true
  if File.exist?(fuse_path)
    if system("ruby", fuse_path.to_s, clean_assets.to_s)
    end
  end
end
```

Create file `ios/MerchantConfig.txt` with the following content

```txt
clientId = <clientId> shared by Juspay Team
```

## Usage

### Import HyperSDK

```dart
import 'package:hypersdk/hypersdkflutter.dart';
```

### Step-1: Create Juspay Object

This method creates an instance of Juspay class on which all the HyperSDK APIs / methods are triggered.

Note: This method is mandatory and is required to call any other subsequent methods from HyperSDK.

```dart
final hyperSDK = HyperSDK();
```

### Step-2: Initiate

This method should be called on the render of the host screen. This will boot up the SDK and start the Hyper engine. It takes a stringified JSON as its argument which will contain the base parameters for the entire session and remains static throughout one SDK instance lifetime. It also takes a function to handle initiate callbacks.

Note: It is highly recommended to initiate SDK from the order summary page (at least 5 seconds before opening your payment page) for seamless user experience.

```dart
await hyperSDK.initiate(initiatePayload, initiateCallbackHandler);
```

### Step-3: Process

This API should be triggered for all operations required from HyperSDK. The operation may be related to:

Displaying payment options on your payment page
Performing a transaction
User's payment profile management

```dart
await hyperSDK.process(processPayload, hyperSDKCallbackHandler)
```

### Step-4: Android Hardware Back-Press Handling

Hyper SDK internally uses an android fragment for opening the bank page and will need the control to hardware back press when the bank page is active.

For Android, this can be done by wrapping your scaffold widget(or any other parent widget) with `WillPopScope` [Flutter Doumentation](https://api.flutter.dev/flutter/widgets/WillPopScope-class.html)

Call `await juspay.onBackPress();` inside `onWillPop` within `WillPopScope`.

Handling Android Hardware Back-Press can be done using `WillPopScope` as shown below

```dart
onWillPop: () async {
        if (Platform.isAndroid) {
          var backpressResult = await hyperSDK.onBackPress();
          if (backpressResult.toLowerCase() == "true") {
            return false;
          } else {
            return true;
          }
        } else {
          return true;
        }
      }
```

### Step-5: Terminate

This method shall be triggered when HyperSDK is no longer required.

```dart
await hyperSDK.terminate();
```

### Optional: Is Initialised

This is a helper / optional method to check whether SDK has been initialised after step-2. It returns a boolean.

```dart
await hyperSDK.isInitialised();
```

## Callbacks

### Initiate callback handler

Use this function to get result from initiate.

```dart
void initiateCallbackHandler(MethodCall methodCall) {
    if (methodCall.method == "initiate_result") {
      // check initiate result
    }
  }
```

### Process callback handler

Use this function to get results from process.

```dart
void hyperSDKCallbackHandler(MethodCall methodCall) {
    switch (methodCall.method) {
      case "hide_loader":
        break;
      case "process_result":
        var args = {};

        try {
          args = json.decode(methodCall.arguments);
        } catch (e) {
          print(e);
        }

        var error = args["error"] ?? false;

        var innerPayload = args["payload"] ?? {};

        var status = innerPayload["status"] ?? " ";
        var pi = innerPayload["paymentInstrument"] ?? " ";
        var pig = innerPayload["paymentInstrumentGroup"] ?? " ";

        if (!error) {
          switch (status) {
            case "charged":
              {
                // Successful Transaction
                // check order status via S2S API
              }
              break;
            case "cod_initiated":
              {
                // User opted for cash on delivery option displayed on payment page
              }
              break;
          }
        } else {
          var errorCode = args["errorCode"] ?? " ";
          var errorMessage = args["errorMessage"] ?? " ";
          switch (status) {
            case "backpressed":
              {
                // user back-pressed from PP without initiating any txn
              }
              break;
            case "user_aborted":
              {
                // user initiated a txn and pressed back
                // check order status via S2S API
              }
              break;
            case "pending_vbv":
              {}
              break;
            case "authorizing":
              {
                // txn in pending state
                // check order status via S2S API
              }
              break;
            case "authorization_failed":
              {}
              break;
            case "authentication_failed":
              {}
              break;
            case "api_failure":
              {
                // txn failed
                // check order status via S2S API
              }
              break;
            case "new":
              {
                // order created but txn failed
                // check order status via S2S API
              }
              break;
          }
        }
    }
  }
```

## Payload Structure

Payload type is `Map<String,Dynamic>`

For Payment Page Product, [click here](https://developer.juspay.in/docs/introduction-6) for payload.

For EC-Headless Product, [click here](https://developer.juspay.in/v2.0/docs/payload) for payload.

## License

hypersdkflutter is distributed under [AGPL-3.0-only](https://pub.dev/packages/hypersdkflutter/license) license.

### Attribution

This project is based on the OSS project juspay_flutter by [Deep Rooted.co](https://deep-rooted.co) published under MIT License

The original repository is accessible [here](https://github.com/deep-rooted-co/juspay_flutter).
