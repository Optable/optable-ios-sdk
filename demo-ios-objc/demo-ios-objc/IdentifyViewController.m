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
#import "demo_ios_objc-Swift.h"

@import OptableSDK;

@interface IdentifyViewController ()
@property (nonatomic, strong, nullable) id networkLogObserver;
@end

@implementation IdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _identifyInput.delegate = self;
    
    OptableSDKDelegate *delegate = (OptableSDKDelegate *)OPTABLE.delegate;
    delegate.identifyOutput = self.identifyOutput;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self startObservingNetworkLogs];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [self stopObservingNetworkLogs];
}

// MARK: - Actions
- (IBAction)dispatchIdentify:(id)sender {
    [self.view endEditing: TRUE];
    
    NSString *email = _identifyInput.text;
    
    NSMutableString *output = [NSMutableString stringWithFormat: @"Calling /identify API with:\n\n"];
    if (email.length > 0) {
        [output appendString: [NSString stringWithFormat: @"Email: %@\n", email]];
    }
    
    _identifyOutput.text = output;
    
    NSError *error = nil;
    
    [OPTABLE identify: @[
        [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_EmailAddress value:email],
        [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_PhoneNumber value:@"+1234567890"],
        [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_AppleIDFA value:@"06DE8C6A-A431-4235-A262-E3A9C2CCEB34"],
        [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_GoogleGAID value:@"D04BB8C3-5A3E-4964-9757-D38365F59E6A"],
        [OptableSDKIdentifier identifierWithRawType:@"c" value:@"new-custom.ABC"],
        [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_Custom value:@"custom-7" customIdx:@7],
        [OptableSDKIdentifier identifierWithString:@"c9:custom-9-id"],
    ]
                error: &error];
}

// MARK: - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return FALSE;
}

// MARK: - Logging
- (void)startObservingNetworkLogs {
    __weak typeof(self) weakSelf = self;
    
    _networkLogObserver = [NSNotificationCenter.defaultCenter
                           addObserverForName: NotificationNames.HTTPURLLogUpdated
                           object: nil
                           queue: [NSOperationQueue mainQueue]
                           usingBlock: ^(NSNotification* notification) {
        HTTPURLLogEntry *logEntry = notification.userInfo[@"data"];
        if (![logEntry isKindOfClass:[HTTPURLLogEntry class]]) {
            return;
        }
        
        NSString *urlString = logEntry.request.URL.absoluteString;
        if ([urlString containsString:@"/identify"]) {
            weakSelf.identifyOutput.text = logEntry.debugDescription;
            
            if (logEntry.response == nil) {
                NSLog(@"%@", logEntry.requestDebugDescription);
            } else {
                NSLog(@"%@", logEntry.responseDebugDescription);
            }
        }
    }];
}

- (void)stopObservingNetworkLogs {
    if (_networkLogObserver != NULL) {
        [NSNotificationCenter.defaultCenter removeObserver: _networkLogObserver];
    }
}

@end
