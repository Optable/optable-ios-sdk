//
//  IdentifyViewController.h
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import <UIKit/UIKit.h>

@interface IdentifyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *identifyInput;
@property (weak, nonatomic) IBOutlet UIButton *identifyButton;
@property (weak, nonatomic) IBOutlet UISwitch *identifyIDFA;
@property (weak, nonatomic) IBOutlet UITextView *identifyOutput;

- (IBAction)dispatchIdentify:(id)sender;
@end

