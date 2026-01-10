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
#import "demo_ios_objc-Swift.h"

@import OptableSDK;
@import GoogleMobileAds;

@interface GAMBannerViewController ()
// GoogleMobileAds - GADBannerView
@property(nonatomic, strong) GADBannerView *gadBannerView;
// Logging
@property(nonatomic, strong, nullable) NSString* targetingLog;
@property(nonatomic, strong, nullable) NSString* witnessLog;
@property(nonatomic, strong, nullable) NSString* profileLog;
@property(nonatomic, strong, nullable) id networkLogObserver;
@end

@implementation GAMBannerViewController

- (NSString *)AD_MANAGER_AD_UNIT_ID {
    return @"/22081946781/ios-sdk-demo/mobile-leaderboard";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gadBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.gadBannerView.adUnitID = self.AD_MANAGER_AD_UNIT_ID;
    self.gadBannerView.rootViewController = self;
    self.gadBannerView.delegate = self;
    [self addBannerViewToView:self.gadBannerView];

    OptableSDKDelegate *delegate = (OptableSDKDelegate *)OPTABLE.delegate;
    delegate.gadBannerView = self.gadBannerView;
    delegate.pbmBannerAdUnit = nil;
    delegate.targetingOutput = self.targetingOutput;
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
- (IBAction)loadBannerWithTargeting:(id)sender {
    NSError *error = nil;
    [OPTABLE targetingWithIds: NULL error: &error];
    [OPTABLE witnessWithEvent: @"GAMBannerViewController.loadBannerClicked"
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
    NSDictionary *cachedTargetingData = [OPTABLE targetingFromCache];

    if (cachedTargetingData != nil) {
        request.customTargeting = cachedTargetingData;
        NSLog(@"[OptableSDK] ✅ Cached targeting values found: %@", cachedTargetingData);
    } else {
        NSLog(@"[OptableSDK] ℹ️ Cache empty");
    }
    
    [(OptableSDKDelegate*)OPTABLE.delegate loadGADAdWithTargetingData:cachedTargetingData];
    [OPTABLE witnessWithEvent: @"GAMBannerViewController.loadBannerClicked"
                   properties: @{ @"example": @"value" }
                        error: &error];
    [OPTABLE profileWithTraits: @{ @"example": @"value", @"anotherExample": @123, @"thirdExample": @YES }
                            id: NULL
                     neighbors: NULL
                         error: &error];
}

- (IBAction)clearTargetingCache:(id)sender {
    [_targetingOutput setText:@"🧹 Cleared local targeting cache.\n"];
    [OPTABLE targetingClearCache];
}

// MARK: - GADBannerViewDelegate
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"[GAMBannerViewController] Failed to receive ad: %@", [error localizedDescription]);
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

- (void)updateUILog {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];

    if (self.targetingLog) {
        [parts addObject:self.targetingLog];
    }
    if (self.witnessLog) {
        [parts addObject:self.witnessLog];
    }
    if (self.profileLog) {
        [parts addObject:self.profileLog];
    }

    self.targetingOutput.text = [parts componentsJoinedByString:@"\n\n"];
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
        if ([urlString containsString:@"/targeting"]) {
            weakSelf.targetingLog = logEntry.debugDescription;
            if (logEntry.response == nil) {
                NSLog(@"%@", logEntry.requestDebugDescription);
            } else {
                NSLog(@"%@", logEntry.responseDebugDescription);
            }
        }
        if ([urlString containsString:@"/witness"]) {
            weakSelf.witnessLog = logEntry.debugDescription;
            if (logEntry.response == nil) {
                NSLog(@"%@", logEntry.requestDebugDescription);
            } else {
                NSLog(@"%@", logEntry.responseDebugDescription);
            }
        }
        if ([urlString containsString:@"/profile"]) {
            weakSelf.profileLog = logEntry.debugDescription;
            if (logEntry.response == nil) {
                NSLog(@"%@", logEntry.requestDebugDescription);
            } else {
                NSLog(@"%@", logEntry.responseDebugDescription);
            }
        }
        
        [weakSelf updateUILog];
    }];
}

- (void)stopObservingNetworkLogs {
    if (_networkLogObserver != NULL) {
        [NSNotificationCenter.defaultCenter removeObserver: _networkLogObserver];
    }
}

@end
