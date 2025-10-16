//
//  AppDelegate.m
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import "AppDelegate.h"
#import "OptableSDKDelegate.h"

@import OptableSDK;

@import PrebidMobile;
@import GoogleMobileAds;

OptableSDK *OPTABLE = nil;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initOptable];
    
    [self initPrebidMobile];
    [self initGoogleMobileAds];

    return YES;
}

- (void)initOptable {
    OPTABLE = [[OptableSDK alloc] initWithHost: @"sandbox.optable.co" app: @"ios-sdk-demo" insecure: NO useragent: nil];
    OptableSDKDelegate *delegate = [[OptableSDKDelegate alloc] init];
    OPTABLE.delegate = delegate;
}

- (void)initPrebidMobile {
    Prebid.shared.prebidServerAccountId = @"0689a263-318d-448b-a3d4-b02e8a709d9d";
    
    [Prebid initializeSDKWithServerURL:@"https://prebid-server-test-j.prebid.org/openrtb2/auction"
                                 error:nil
                                      :nil];
}

- (void)initGoogleMobileAds {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {}];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {}

@end
