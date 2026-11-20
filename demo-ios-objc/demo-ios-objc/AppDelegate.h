//
//  AppDelegate.h
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import <UIKit/UIKit.h>
@import OptableSDK;

extern OptableSDK *OPTABLE;

/// SHA256 of the Email, normalized the way the SDK does it for OptableSDKIdentifierType_EmailAddress: whitespace removed, lowercased.
NSString *OptableDemoSHA256Email(NSString *email);

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@end
