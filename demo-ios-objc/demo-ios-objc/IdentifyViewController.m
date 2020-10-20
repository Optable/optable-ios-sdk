//
//  IdentifyViewController.m
//  demo-ios-objc
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

#import "OptableSDKDelegate.h"
#import "IdentifyViewController.h"
#import "AppDelegate.h"
@import OptableSDK;

@interface IdentifyViewController ()
@end

@implementation IdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    OptableSDKDelegate *delegate = (OptableSDKDelegate *)OPTABLE.delegate;
    delegate.identifyOutput = self.identifyOutput;
}

- (void)dispatchIdentify:(id)sender {
    NSString *email = [_identifyInput text];
    bool aaid = [_identifyIDFA isOn];
    NSMutableString *output;
    NSError *error = nil;

    output = [NSMutableString stringWithFormat:@"Calling /identify API with:\n\n"];
    if ([email length] > 0) {
        [output appendString:[NSString stringWithFormat:@"Email: %@\n", email]];
    }
    [output appendString:[NSString stringWithFormat:@"IDFA: %s\n", aaid ? "true" : "false"]];
    [_identifyOutput setText:output];

    [OPTABLE identify :email aaid:aaid ppid:@"" error:&error];
}

@end
