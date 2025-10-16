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

@interface OptableSDKDelegate ()
@end

@implementation OptableSDKDelegate
- (void)identifyOk:(NSHTTPURLResponse *)result {
    NSLog(@"[OptableSDK] Success on /identify API call. HTTP Status Code: %ld", result.statusCode);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.identifyOutput setText:[NSString stringWithFormat:@"%@\n✅ Success", [self.identifyOutput text]]];
    });
}
- (void)identifyErr:(NSError *)error {
    NSLog(@"[OptableSDK] Error on /identify API call: %@", [error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.identifyOutput setText:[NSString stringWithFormat:@"%@\n🚫 Error: %@\n", [self.identifyOutput text], [error localizedDescription]]];
    });
}
- (void)profileOk:(NSHTTPURLResponse *)result {
    NSLog(@"[OptableSDK] Success on /profile API call. HTTP Status Code: %ld", result.statusCode);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetingOutput setText:[NSString stringWithFormat:@"%@\n✅ Success calling profile API to set example traits.\n", [self.targetingOutput text]]];
    });
}
- (void)profileErr:(NSError *)error {
    NSLog(@"[OptableSDK] Error on /profile API call: %@", [error localizedDescription]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetingOutput setText:[NSString stringWithFormat:@"%@\n🚫 Error: %@\n", [self.targetingOutput text], [error localizedDescription]]];
    });
}
- (void)targetingOk:(NSDictionary *)result {
    // Update the GAM banner view with result targeting keyvalues:
    GAMRequest *request = [GAMRequest request];
    request.customTargeting = result;
    [self.adManagerBannerView loadRequest:request];

    NSLog(@"[OptableSDK] Success on /targeting API call: %@", result);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetingOutput setText:[NSString stringWithFormat:@"%@\n✅ Data: %@\n", [self.targetingOutput text], result]];
    });
}
- (void)targetingErr:(NSError *)error {
    // Update the GAM banner view without targeting data:
    GAMRequest *request = [GAMRequest request];
    [self.adManagerBannerView loadRequest:request];

    NSLog(@"[OptableSDK] Error on /targeting API call: %@", [error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetingOutput setText:[NSString stringWithFormat:@"%@\n🚫 Error: %@\n", [self.targetingOutput text], [error localizedDescription]]];
    });
}
- (void)witnessOk:(NSHTTPURLResponse *)result {
    NSLog(@"[OptableSDK] Success on /witness API call. HTTP Status Code: %ld", result.statusCode);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetingOutput setText:[NSString stringWithFormat:@"%@\n✅ Success calling witness API to log loadBannerClicked event.\n", [self.targetingOutput text]]];
    });
}
- (void)witnessErr:(NSError *)error {
    NSLog(@"[OptableSDK] Error on /witness API call: %@", [error localizedDescription]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetingOutput setText:[NSString stringWithFormat:@"%@\n🚫 Error: %@\n", [self.targetingOutput text], [error localizedDescription]]];
    });
}

- (void)loadBannerWithKeyValues:(NSDictionary<NSString *, NSString *> * _Nullable)keyValues {
    GAMRequest *request = [GAMRequest request];
    
    if (self.pbmBannerAdUnit) {
        __weak typeof(self) weakSelf = self;
        [self.pbmBannerAdUnit fetchDemandWithAdObject:request completion:^(enum ResultCode status) {
            if (status != ResultCodePrebidDemandFetchSuccess) {
                NSLog(@"[PrebidMobile SDK] Prebid fetch demand failed: %ld", (long)status);
            }
            if (keyValues.count > 0) {
                NSMutableDictionary *merged = [request.customTargeting mutableCopy] ?: [NSMutableDictionary dictionary];
                [merged addEntriesFromDictionary:keyValues];
                request.customTargeting = merged;
            }
            [weakSelf.adManagerBannerView loadRequest:request];
        }];
    } else {
        if (keyValues.count > 0) {
            request.customTargeting = keyValues;
        }
        [self.adManagerBannerView loadRequest:request];
    }
}

@end
