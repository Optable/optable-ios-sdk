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

@import AppTrackingTransparency;
@import OptableSDK;

@interface IdentifyViewController ()
@property (nonatomic, strong, nullable) id networkLogObserver;
@end

@implementation IdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _identifyInput.delegate = self;
    _identifyURLInput.delegate = self;
    
    // A link like the ones in a newsletter Email, carrying the SHA256 of the reader's Email address
    _identifyURLInput.text = [NSString stringWithFormat:@"https://example.com/newsletter?oeid=%@", OptableDemoSHA256Email(@"some.email@address.com")];
    
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
    
    // If the user gives consent to be tracked - IDFA will be added
    // automatically to the list of identifiers,
    // either in the `identify` or `targeting` calls
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            
            [OPTABLE identify: @[
                [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_EmailAddress value:email],
                [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_PhoneNumber value:@"+1234567890"],
                [OptableSDKIdentifier identifierWithRawType:@"c" value:@"new-custom.ABC"],
                [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_Custom value:@"custom-7" customIdx:@7],
                [OptableSDKIdentifier identifierWithString:@"c9:custom-9-id"],
            ]
                        error: &error];
        });
    }];
}

// dispatchIdentifyHashed: sends the Email as a SHA256 hashed in the app, as you would with a hash from your own backend.
// OptableSDKIdentifierType_HEM sends it as given; passing a hash as OptableSDKIdentifierType_EmailAddress would hash it a second time.
- (IBAction)dispatchIdentifyHashed:(id)sender {
    [self.view endEditing: TRUE];
    
    NSError *error = nil;
    [OPTABLE identify: @[
        [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_HEM value:OptableDemoSHA256Email(_identifyInput.text ?: @"")],
    ]
                error: &error];
}

// dispatchIdentifyFromURL: passes a link to tryIdentifyFromURL:, as you would from a universal link handler.
// If the link has an `oeid` query parameter holding a SHA256, the SDK calls /identify with it; otherwise it does nothing.
- (IBAction)dispatchIdentifyFromURL:(id)sender {
    [self.view endEditing: TRUE];
    
    NSError *error = nil;
    [OPTABLE tryIdentifyFromURL: _identifyURLInput.text ?: @"" error: &error];
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
