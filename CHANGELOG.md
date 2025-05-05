# 4.0.30
* fixed ios compile issue (#66)Co-authored-by: Sahaya Gebin <sahaya.gebin@Sahaya-Gebin-JGC9HGHHCW.local>

# 4.0.29
* added support for multiple tenants in plugin

# 4.0.28
* fix: invoking isInitialised method (#63)

# 4.0.27
* Updated android and iOS sdk version to 2.2.1  2.2.2 respectively (#56)

# 4.0.26
* fix : Updated android and iOS sdk version to 2.2.1 & 2.2.2 respectively.

# 4.0.25
* feat: added webview configuration callback for minkasu support

# 4.0.24
* fix: Fixed issue github workflow (#53)

# 4.0.23
* Fixed issue in github workflow

# 4.0.22
* Added github actions workflow

# 4.0.21
* Bug fix in process with Container API.
* Updated IOS SDK Version to 2.2.1.7
* Fixed typo for flutter method hyperSdkView.

# 4.0.20
* Crash fix in IOS process call for forcefully unwrapping nil
* Removed forceful unwrapping in Android

# 4.0.19
* Added support to statically pin hyperAssetVersion.

# 4.0.18
* Updated HyperSDK version for iOS to 2.1.43 and for Android, 2.1.32.
* Added HyperSDK Override support for IOS.

# 4.0.17
* Removing activity from process call.
* Added support to exclude microSdks.
* Updated HyperSdk plugin version to 2.0.7.

# 4.0.16
* Updated HyperSDK version for iOS to 2.1.40.
* Added support to render Payment Page UI within merchant container. Refer [this](README.md#step-31-process-via-container) for more information.

# 4.0.15

* Updated HyperSDK version for IOS to 2.1.39.
* Updated HyperSDK version for Android to 2.1.25.
* Blocked click events to merchant screen in IOS.

# 4.0.14

* Updated HyperSDK version for IOS to 2.1.35.
* Making IOS HyperSDK instance creation on demand instead of creating it on plugin initiate.

# 4.0.13

* Updated HyperSDK version for Android.

# 4.0.12

* Removed legacy integration documentation.

# 4.0.11

* Updated Updated HyperSDK version for Android & IOS.

# 4.0.10

* Updated README file.
* Updated HyperSdk plugin version to 2.0.6

# 4.0.9

* Updated IOS SDK version to 2.1.30
* Added openPaymentPage that calls initiate and process together using HyperCheckoutLite openPaymentPage Function for IOS.

# 4.0.8

* Moved SDK instance creation to initiate.

# 4.0.7

* Updated IOS SDK Version to 2.1.28.

# 4.0.6

* Updated Android SDK Version to 2.1.20

# 4.0.5

* Bug fix in HyperCheckoutLite's openPaymentPage Function

# 4.0.4

* added openPaymentPage that calls initiate and process together using HyperCheckoutLite openPaymentPage Function

# 4.0.3

* Updated android plugin version to 2.0.4

# 4.0.2

* Updated IOS SDK Version to 2.1.26.

# 4.0.1

* Updated Android SDK Version to 2.1.13.

# 4.0.0

* Upgraded to HyperSDK Plugin 2.0. Refer [README.md](README.md#migration-guide-android-30x-to-4yx) for the migration steps.
* Updated Android SDK Version to 2.1.12.

# 3.1.1

* Updated HyperSDK Android Plugin to 2.0.2

# 3.1.0

* Upgraded to HyperSDK Plugin 2.0. Refer [README.md](README.md#migration-guide-android-30x-to-31x) for the migration steps.
* Updated Android SDK Version to 2.1.12.

# 3.0.11

* Updated IOS SDK Version to 2.1.22 & Android SDK Version to 2.1.11.

# 3.0.10

* Updated Android SDK Version to 2.1.10

# 3.0.9

* Updated Android SDK Version to 2.1.9 and IOS SDK version to 2.1.15

# 3.0.8

* Updated Android SDK Version to 2.1.8 and IOS SDK version to 2.1.17

# 3.0.7

* Added flag to identify if the integration is flutter in android

# 3.0.6

* Updated LICENSE to AGPL-3.0

# 3.0.5

* Adding initial developer attribution to this plugin

# 3.0.4

* Updated Android SDK Version to 2.1.2

# 3.0.3

* Updated code formatting in README.md

# 3.0.2

* Updated documentation/Readme.md for flutter plugin

# 3.0.1

* Updating plugin name to hypersdkflutter to avoid conflict with HyperSDK
* Updating minSDKVersion for android to 19 as it's minimum suported version for our SDK.
* Changing HyperSDK version for IOS to 2.0.15

# 3.0.0

* Updating the Major Version
* Adding Example project in the plugin
* Adding descriptive error message for FlutterFragmentActivity Exception
* Added Plugin Integration example app with Initiate being called in HomeScreen

# 2.0.4

* Flutter 3 support
* Fixed error method signature of invokeMethodResult Object
* Updated kotlin version to minimum version supported by Flutter 3

# 2.0.2

* Updating release for public

# 2.0.0

* First version release for publishing.
