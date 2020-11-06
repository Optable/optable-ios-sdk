//
//  GAMBannerViewController.h
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import <UIKit/UIKit.h>

@interface GAMBannerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loadBannerButton;
@property (weak, nonatomic) IBOutlet UIButton *cachedBannerButton;
@property (weak, nonatomic) IBOutlet UIButton *clearTargetingCacheButton;
@property (weak, nonatomic) IBOutlet UITextView *targetingOutput;

- (IBAction)loadBannerWithTargeting:(id)sender;
@end
