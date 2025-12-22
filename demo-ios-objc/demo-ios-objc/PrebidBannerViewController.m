//
//  PrebidBannerViewController.m
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import "OptableSDKDelegate.h"
#import "PrebidBannerViewController.h"
#import "AppDelegate.h"

@import OptableSDK;
@import GoogleMobileAds;

@interface PrebidBannerViewController ()

@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) BannerAdUnit *pbmBannerAdUnit;

@end

@implementation PrebidBannerViewController

- (NSString *)AD_MANAGER_AD_UNIT_ID {
    return @"/21808260008/prebid_demo_app_original_api_banner";
}

- (NSString *)PREBID_STORED_IMP {
    return @"prebid-demo-banner-320-50";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.bannerView.adUnitID = self.AD_MANAGER_AD_UNIT_ID;
    self.bannerView.rootViewController = self;
    [self addBannerViewToView:self.bannerView];
    
    self.pbmBannerAdUnit = [[BannerAdUnit alloc] initWithConfigId:self.PREBID_STORED_IMP
                                                             size:CGSizeMake(320, 50)];

    OptableSDKDelegate *delegate = (OptableSDKDelegate *)OPTABLE.delegate;
    delegate.adManagerBannerView = self.bannerView;
    delegate.pbmBannerAdUnit = self.pbmBannerAdUnit;
    delegate.targetingOutput = self.targetingOutput;
}

- (IBAction)loadBannerWithTargeting:(id)sender {
    NSError *error = nil;

    [_targetingOutput setText:@"📡 Calling /targeting API...\n"];
    
    [OPTABLE targetingWithIds: NULL error: &error];
    [OPTABLE witnessWithEvent: @"PrebidBannerViewController.loadBannerClicked"
                   properties: @{ @"example": @"value" }
                        error: &error];
    [OPTABLE profileWithTraits: @{ @"example": @"value", @"anotherExample": @123, @"thirdExample": @YES }
                            id: NULL
                     neighbors: NULL
                         error: &error];
}

- (IBAction)loadBannerWithTargetingFromCache:(id)sender {
    NSError *error = nil;
    GAMRequest *request = [GAMRequest request];
    NSDictionary *keyvals = nil;

    [_targetingOutput setText:@"🗂 Checking local targeting cache...\n\n"];

    keyvals = [OPTABLE targetingFromCache];

    if (keyvals != nil) {
        request.customTargeting = keyvals;
        NSLog(@"[OptableSDK] Cached targeting values found: %@", keyvals);
        [_targetingOutput setText:[NSString stringWithFormat:@"%@\n✅ Found cached data: %@\n", [_targetingOutput text], keyvals]];
    } else {
        [_targetingOutput setText:[NSString stringWithFormat:@"%@\nℹ️ Cache empty.\n",
            [_targetingOutput text]]];
    }

    [self.bannerView loadRequest:request];
    
    
    [OPTABLE witnessWithEvent: @"PrebidBannerViewController.loadBannerClicked"
                   properties: @{ @"example": @"value" }
                        error: &error];
    [OPTABLE profileWithTraits: @{ @"example": @"value", @"anotherExample": @123, @"thirdExample": @YES }
                            id: NULL
                     neighbors: NULL
                         error: &error];
}

- (IBAction)clearTargetingCache:(id)sender {
    [_targetingOutput setText:@"🧹 Clearing local targeting cache.\n"];
    [OPTABLE targetingClearCache];
}

// MARK: - Helpers

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.adPlaceholder addSubview:bannerView];
    
    [NSLayoutConstraint activateConstraints:@[
        [bannerView.centerXAnchor constraintEqualToAnchor:self.adPlaceholder.centerXAnchor],
        [bannerView.centerYAnchor constraintEqualToAnchor:self.adPlaceholder.centerYAnchor]
    ]];
}

@end
