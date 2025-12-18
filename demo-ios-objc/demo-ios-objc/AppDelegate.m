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

OptableSDK *OPTABLE = nil;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    OptableSDKDelegate *delegate = [OptableSDKDelegate new];
    
    OptableConfig *config = [[OptableConfig alloc] initWithTenant: @"prebidtest" originSlug: @"ios-sdk"];
    config.host = @"prebidtest.cloud.optable.co";
    
    OPTABLE = [[OptableSDK alloc] initWithConfig: config];
    OPTABLE.delegate = delegate;
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {}

@end
