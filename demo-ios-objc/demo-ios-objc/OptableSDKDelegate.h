//
//  OptableSDKDelegate.h
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

@import OptableSDK;
@import GoogleMobileAds;

@interface OptableSDKDelegate: NSObject <OptableDelegate>

@property(atomic, readwrite, strong) GADBannerView *bannerView;
@property(atomic, readwrite, strong) UITextView *identifyOutput;
@property(atomic, readwrite, strong) UITextView *targetingOutput;

@end
