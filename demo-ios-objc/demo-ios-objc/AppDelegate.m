//
//  AppDelegate.m
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import "AppDelegate.h"
#import "OptableSDKDelegate.h"
#import "demo_ios_objc-Swift.h"

@import OptableSDK;
@import PrebidMobile;
@import GoogleMobileAds;


OptableSDK *OPTABLE = nil;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Debug URLSession
    [NSURLProtocol registerClass: [HTTPURLLogProtocol class]];
    
    OptableSDKDelegate *delegate = [OptableSDKDelegate new];
    
    OptableConfig *config = [[OptableConfig alloc] initWithTenant: @"prebidtest" originSlug: @"ios-sdk"];
    config.host = @"prebidtest.cloud.optable.co";
    
    OPTABLE = [[OptableSDK alloc] initWithConfig: config];
    OPTABLE.delegate = delegate;
    
    [self initPrebidMobile];
    [self initGoogleMobileAds];

    return YES;
}

- (void)initPrebidMobile {
    Prebid.shared.prebidServerAccountId = @"0689a263-318d-448b-a3d4-b02e8a709d9d";
    
    [Prebid initializeSDKWithServerURL: @"https://prebid-server-test-j.prebid.org/openrtb2/auction"
                                 error: nil
                                      : nil];
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
