# Hyper SDK Flutter

Flutter plugin for HyperSDK which enables payment orchestration via different dynamic modules.

## Flutter Setup

Add flutter plugin dependency in `pubspec.yaml`.
Get dependency from [pub.dev](https://pub.dev/packages/hypersdkflutter/install)


## To Run the Demo app

### Provide Customer and Merchant Details

Provide the cutomer and merchant details in the example/lib/screens/home.dart file 

```
var customerDetails = {
    "customerId" : "",
    "customerPhone" : "",
    "customerEmail": ""
};

var merchantDetails = {
    "clientId": "",
    "merchantId": "",
    "action": "",
    "returnUrl": "",
    "currency": "INR",
    "privateKey": "",
    "merchantKeyId": "",
    "environment": "",
    "service": ""
};

```

### In Android

Navigate to example/android/build.gradle -> buildscript -> ext -> clientId, provide the clientId given to you by Juspay team.


### In IOS

Navigate to example/ios/MerchantConfig.txt, provide the clientId provided by the Juspay team.


### Run the project

Navigate to example ( cd example). Run the command

```
flutter run

```
