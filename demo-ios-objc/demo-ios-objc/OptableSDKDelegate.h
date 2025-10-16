//
//  OptableSDKDelegate.h
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

@import OptableSDK;

@import PrebidMobile;
@import GoogleMobileAds;

@interface OptableSDKDelegate: NSObject <OptableDelegate>

// MARK: - PrebidMobile
@property(atomic, readwrite, weak) BannerAdUnit *pbmBannerAdUnit;

// MARK: - GoogleMobileAds
@property(atomic, readwrite, weak) GADBannerView *adManagerBannerView;

// MARK: - Text Output
@property(atomic, readwrite, strong) UITextView *identifyOutput;
@property(atomic, readwrite, strong) UITextView *targetingOutput;

@end
