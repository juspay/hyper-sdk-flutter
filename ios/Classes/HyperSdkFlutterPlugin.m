/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "HyperSdkFlutterPlugin.h"
#if __has_include(<hypersdkflutter/hypersdkflutter-Swift.h>)
#import <hypersdkflutter/hypersdkflutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "hypersdkflutter-Swift.h"
#endif

@implementation HyperSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHyperSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
