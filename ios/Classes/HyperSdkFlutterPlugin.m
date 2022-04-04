#import "HyperSdkFlutterPlugin.h"
#if __has_include(<hypersdk/hypersdk-Swift.h>)
#import <hypersdk/hypersdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "hypersdk-Swift.h"
#endif

@implementation HyperSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHyperSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
