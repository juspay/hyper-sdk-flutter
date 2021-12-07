#import "HyperSdkFlutterPlugin.h"
#if __has_include(<hyper_sdk_flutter/hyper_sdk_flutter-Swift.h>)
#import <hyper_sdk_flutter/hyper_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "hyper_sdk_flutter-Swift.h"
#endif

@implementation HyperSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHyperSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
