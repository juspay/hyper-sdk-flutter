# Hyper SDK Flutter

Flutter plugin for HyperSDK which enables payment orchestration via different dynamic modules. 
For more details, refer [Payment Page SDK](https://developer.juspay.in/v4.0/docs/introduction)

## Flutter Setup

Add flutter plugin dependency in `pubspec.yaml`

```yaml
hyper_sdk_flutter:
    git:
      url: https://bitbucket.org/juspay/hyper-sdk-flutter.git
      ref: master
```

## Android Setup

Add the build dependency in  `android/build.gradle` file

```groovy
buildscript {
    ....
    repositories {
        ....
        maven {
            url "https://maven.juspay.in/jp-build-packages/hypersdk-asset-download/releases/"
        }
    }

    dependencies {
        ....
        classpath 'in.juspay:hypersdk-asset-plugin:1.0.3'
    }
}
```

Apply the plugin to the application module in `android/app/build.gradle` file

```groovy
apply plugin: 'hypersdk-asset-plugin'
```

Add file `MerchantConfig.txt` in the same directory`(android/app/)`as the gradle file in the previous step with the following content

```txt
clientId = <your client id>
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
clientId = <your client id>
```

## Usage

### Import HyperSDK

`import 'package:hyper_sdk_flutter/hyper_sdk_flutter.dart';`

### Step-0: PreFetch

To keep the SDK up to date with the latest changes, it is highly recommended to call preFetch as early as possible. It takes a stringified JSON as its argument.

`await Juspay.preFetch(preFetchPayload);`

### Step-1: Create Juspay Object

This method creates an instance of Juspay class on which all the HyperSDK APIs / methods are triggered.

Note: This method is mandatory and is required to call any other subsequent methods from HyperSDK.

```dart
final juspay = Juspay(
      onShowLoader: () {
        // show the loader
      },
      onHideLoader: () {
        // stop the processing loader 
      },
      onInitiateResult: () {
        // handle initiate response -- log it
        // do what you want here
      },
      onProcessResult: (){
        // handle process response -- log it
        // do what you want here
      });
```

### Step-2: Initiate

This method should be called on the render of the host screen. This will boot up the SDK and start the Hyper engine. It takes a stringified JSON as its argument which will contain the base parameters for the entire session and remains static throughout one SDK instance lifetime.

Note: It is highly recommended to initiate SDK from the order summary page (at least 5 seconds before opening your payment page) for seamless user experience.

`await juspay.initiate(initiatePayload);`

### Step-3: Process

This API should be triggered for all operations required from HyperSDK. The operation may be related to:

Displaying payment options on your payment page
Performing a transaction
User's payment profile management

`await juspay.process(processPayload);`

### Step-4: Android Hardware Back-Press Handling

Hyper SDK internally uses an android fragment for opening the bank page and will need the control to hardware back press when the bank page is active.

For Android, this can be done by wrapping your scaffold widget(or any other parent widget) with `WillPopScope` [Flutter Doumentation](https://api.flutter.dev/flutter/widgets/WillPopScope-class.html)

Call `await juspay.onBackPress();` inside `onWillPop` within `WillPopScope`.

Handling Android Hardware Back-Press can be done using `WillPopScope` as shown below

```dart
onWillPop: () async {
        if (Platform.isAndroid) {
          var backpressResult = await juspay.onBackPress();
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

`await juspay.terminate();`

### Optional: Is Initialised

This is a helper / optional method to check whether SDK has been initialised after step-2. It returns a boolean.

`await juspay.isInitialised();`

## Payload Strcuture

Payload type is `Map<String,Dynamic>`

Please refer [Payment Page Payload](https://developer.juspay.in/v4.0/docs/payload) for request and response payload structure.