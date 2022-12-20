#import "TnkFlutterRwdPlugin.h"
#if __has_include(<tnk_flutter_rwd/tnk_flutter_rwd-Swift.h>)
#import <tnk_flutter_rwd/tnk_flutter_rwd-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tnk_flutter_rwd-Swift.h"
#endif

@implementation TnkFlutterRwdPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTnkFlutterRwdPlugin registerWithRegistrar:registrar];
}
@end
