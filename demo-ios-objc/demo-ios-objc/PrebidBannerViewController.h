//
//  PrebidBannerViewController.h
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GADBannerViewDelegate.h"

@interface PrebidBannerViewController : UIViewController <GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adPlaceholder;

@property (weak, nonatomic) IBOutlet UIButton *loadBannerButton;
@property (weak, nonatomic) IBOutlet UIButton *cachedBannerButton;
@property (weak, nonatomic) IBOutlet UIButton *clearTargetingCacheButton;
@property (weak, nonatomic) IBOutlet UITextView *targetingOutput;

- (IBAction)loadBannerWithTargeting:(id)sender;

@end
