//
//  GAMBannerViewController.m
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import "OptableSDKDelegate.h"
#import "GAMBannerViewController.h"
#import "AppDelegate.h"
@import OptableSDK;
@import GoogleMobileAds;

@interface GAMBannerViewController ()
@property(nonatomic, strong) GADBannerView *bannerView;
@end

@implementation GAMBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.bannerView.adUnitID = @"/22081946781/ios-sdk-demo/mobile-leaderboard";
    [self addBannerViewToView:self.bannerView];
    self.bannerView.rootViewController = self;

    OptableSDKDelegate *delegate = (OptableSDKDelegate *)OPTABLE.delegate;
    delegate.bannerView = self.bannerView;
    delegate.targetingOutput = self.targetingOutput;
}

- (IBAction)loadBannerWithTargeting:(id)sender {
    NSError *error = nil;

    [_targetingOutput setText:@"Calling /targeting API...\n\n"];

    [OPTABLE targetingAndReturnError:&error];
    [OPTABLE witness:@"GAMBannerViewController.loadBannerClicked" properties:@{ @"example": @"value" } error:&error];
    [OPTABLE profileWithTraits:@{ @"example": @"value", @"anotherExample": @123, @"thirdExample": @YES } error:&error];
}

- (IBAction)loadBannerWithTargetingFromCache:(id)sender {
    NSError *error = nil;
    GAMRequest *request = [GAMRequest request];
    NSDictionary *keyvals = nil;

    [_targetingOutput setText:@"Checking local targeting cache...\n\n"];

    keyvals = [OPTABLE targetingFromCache];

    if (keyvals != nil) {
        request.customTargeting = keyvals;
        NSLog(@"[OptableSDK] Cached targeting values found: %@", keyvals);
        [_targetingOutput setText:[NSString stringWithFormat:@"%@\nFound cached data: %@\n", [_targetingOutput text], keyvals]];
    } else {
        [_targetingOutput setText:[NSString stringWithFormat:@"%@\nCache empty.\n",
            [_targetingOutput text]]];
    }

    [self.bannerView loadRequest:request];
    [OPTABLE witness:@"GAMBannerViewController.loadBannerClicked" properties:@{ @"example": @"value" } error:&error];
    [OPTABLE profileWithTraits:@{ @"example": @"value", @"anotherExample": @123, @"thirdExample": @YES } error:&error];
}

- (IBAction)clearTargetingCache:(id)sender {
    [_targetingOutput setText:@"Clearing local targeting cache.\n\n"];
    [OPTABLE targetingClearCache];
}

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    
    [NSLayoutConstraint activateConstraints:@[
        [bannerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [bannerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
}

@end
