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
@property(atomic, readwrite, weak, nullable) BannerAdUnit *pbmBannerAdUnit;

// MARK: - GoogleMobileAds
@property(atomic, readwrite, weak, nullable) GADBannerView *gadBannerView;

// MARK: - Text Output
@property(atomic, readwrite, strong, nullable) UITextView *identifyOutput;
@property(atomic, readwrite, strong, nullable) UITextView *targetingOutput;

// MARK: - Ad Loading
- (void)loadGADAdWithTargetingData:(OptableTargeting* _Nullable)optableTargeting;
- (void)loadPrebidAdWithTargetingData:(OptableTargeting* _Nullable)optableTargeting;
- (void)setOptableTargetingToPrebidWith:(OptableTargeting* _Nullable)optableTargeting;
- (void)loadGADAdWithAdRequest:(GAMRequest* _Nonnull)adRequest;

@end
