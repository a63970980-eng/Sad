#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"

@UIApplicationMain
@interface AppDelegate : FlutterAppDelegate
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
