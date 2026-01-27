//
//  OptableSDKDelegate.m
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import "OptableSDKDelegate.h"
@import OptableSDK;
@import GoogleMobileAds;
@import PrebidMobile;

// MARK: - OptableSDKDelegate
@implementation OptableSDKDelegate
- (void)identifyOk:(NSHTTPURLResponse *)result {
    NSLog(@"[OptableSDK] ✅ Success on /identify API call");
}

- (void)identifyErr:(NSError *)error {
    NSLog(@"[OptableSDK] 🚫 Error on /identify API call: %@", [error localizedDescription]);
}

- (void)profileOk:(OptableTargeting *)result {
    NSLog(@"[OptableSDK] ✅ Success on /profile API call: %@", result.debugDescription);
}

- (void)profileErr:(NSError *)error {
    NSLog(@"[OptableSDK] 🚫 Error on /profile API call: %@", [error localizedDescription]);
}

- (void)targetingOk:(OptableTargeting *)result {
    NSLog(@"[OptableSDK] ✅ Success on /targeting API call: %@", result.debugDescription);
    
    if (_pbmBannerAdUnit != nil) {
        // PrebidBannerViewController
        [self loadPrebidAdWithTargetingData:result];
    } else {
        // GAMBannerViewController
        [self loadGADAdWithTargetingData:result];
    }
}

- (void)targetingErr:(NSError *)error {
    NSLog(@"[OptableSDK] 🚫 Error on /targeting API call: %@", [error localizedDescription]);
    
    // Update the GAM banner view without targeting data:
    [self loadGADAdWithTargetingData:nil];
}

- (void)witnessOk:(NSHTTPURLResponse *)result {
    NSLog(@"[OptableSDK] ✅ Success on /witness API call");
}

- (void)witnessErr:(NSError *)error {
    NSLog(@"[OptableSDK] 🚫 Error on /witness API call: %@", [error localizedDescription]);
}

// MARK: - Ad Loading
- (void)loadGADAdWithTargetingData:(OptableTargeting* _Nullable)optableTargeting {
    GAMRequest *adRequest = [GAMRequest request];
    
    if (optableTargeting != nil && optableTargeting.gamTargetingKeywords != nil) {
        adRequest.customTargeting = optableTargeting.gamTargetingKeywords;
    }
    
    [self loadGADAdWithAdRequest:adRequest];
}

- (void)loadPrebidAdWithTargetingData:(OptableTargeting* _Nullable)optableTargeting {
    [self setOptableTargetingToPrebidWith:optableTargeting];
    
    GAMRequest *adRequest = [GAMRequest request];
    
    if (optableTargeting != nil && optableTargeting.gamTargetingKeywords != nil) {
        adRequest.customTargeting = optableTargeting.gamTargetingKeywords;
    }
    
    [_pbmBannerAdUnit fetchDemandWithAdObject:adRequest completion: ^(enum ResultCode result) {
        NSLog(@"[PrebidMobile]:fetchDemand(adObject:): %ld", (long)result);
        [self loadGADAdWithAdRequest:adRequest];
    }];
}

- (void)setOptableTargetingToPrebidWith:(OptableTargeting* _Nullable)optableTargeting {
    if (optableTargeting == nil || optableTargeting.ortb2 == nil || optableTargeting.ortb2.length == 0) {
        [Targeting.shared setGlobalORTBConfig:nil];
        return;
    }
    
    [Targeting.shared setGlobalORTBConfig:optableTargeting.ortb2];
}

- (void)loadGADAdWithAdRequest:(GAMRequest*)adRequest {
    [_gadBannerView loadRequest:adRequest];
}

@end
