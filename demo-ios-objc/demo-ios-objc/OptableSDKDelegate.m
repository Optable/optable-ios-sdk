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

- (void)profileOk:(NSHTTPURLResponse *)result {
    NSLog(@"[OptableSDK] ✅ Success on /profile API call");
}

- (void)profileErr:(NSError *)error {
    NSLog(@"[OptableSDK] 🚫 Error on /profile API call: %@", [error localizedDescription]);
}

- (void)targetingOk:(NSDictionary *)result {
    NSLog(@"[OptableSDK] ✅ Success on /targeting API call: %@", result);
    
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
- (void)loadGADAdWithTargetingData:(NSDictionary* _Nullable)targetingData {
    GAMRequest *adRequest = [GAMRequest request];
    adRequest.customTargeting = targetingData;
    [self loadGADAdWithAdRequest:adRequest];
}

- (void)loadPrebidAdWithTargetingData:(NSDictionary* _Nullable)targetingData {
    [self setOptableTargetingToPrebidWith:targetingData];
    
    GAMRequest *adRequest = [GAMRequest request];
    adRequest.customTargeting = targetingData;
    [_pbmBannerAdUnit fetchDemandWithAdObject:adRequest completion: ^(enum ResultCode result) {
        NSLog(@"[PrebidMobile]:fetchDemand(adObject:): %ld", (long)result);
        [self loadGADAdWithAdRequest:adRequest];
    }];
}

- (void)setOptableTargetingToPrebidWith:(NSDictionary* _Nullable)targetingData {
    if (targetingData == nil || targetingData.count == 0) {
        [Targeting.shared setGlobalORTBConfig:nil];
        return;
    }

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:targetingData
                                                       options:0
                                                         error:&error];

    if (jsonData == nil) {
        return;
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (jsonString) {
        [Targeting.shared setGlobalORTBConfig:jsonString];
    }
}

- (void)loadGADAdWithAdRequest:(GAMRequest*)adRequest {
    [_gadBannerView loadRequest:adRequest];
}

@end
