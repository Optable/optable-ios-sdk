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
@property(nonatomic, strong) DFPBannerView *bannerView;
@end

@implementation GAMBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.adUnitID = @"/22081946781/ios-sdk-demo/mobile-leaderboard";
    [self addBannerViewToView:self.bannerView];
    self.bannerView.rootViewController = self;

    OptableSDKDelegate *delegate = (OptableSDKDelegate *)OPTABLE.delegate;
    delegate.bannerView = self.bannerView;
    delegate.targetingOutput = self.targetingOutput;
}

- (void)loadBannerWithTargeting:(id)sender {
    NSError *error = nil;

    [_targetingOutput setText:@"Calling /targeting API...\n\n"];

    [OPTABLE targetingAndReturnError:&error];
    [OPTABLE witness:@"GAMBannerViewController.loadBannerClicked" properties:@{ @"example": @"value" } error:&error];
}

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    [self.view addConstraints:@[
      [NSLayoutConstraint constraintWithItem:bannerView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.bottomLayoutGuide
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0],
      [NSLayoutConstraint constraintWithItem:bannerView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0]
                                  ]];
}

@end
