## Usage (Objective-C)

Configuring an instance of the `OptableSDK` from an Objective-C application is similar to the above Swift example, except that the caller should set up an `OptableDelegate` protocol delegate. The first step is to implement the delegate itself, for example, in an `OptableSDKDelegate.h`:

```objective-c
@import OptableSDK;

@interface OptableSDKDelegate: NSObject <OptableDelegate>
@end
```

And in the accompanying `OptableSDKDelegate.m` follows a simple implementation of the delegate calling `NSLog()`:

```objective-c
#import "OptableSDKDelegate.h"
@import OptableSDK;

@interface OptableSDKDelegate ()
@end

@implementation OptableSDKDelegate
- (void)identifyOk:(NSHTTPURLResponse *)result {
    NSLog(@"Success on identify API call. HTTP Status Code: %ld", result.statusCode);
}
- (void)identifyErr:(NSError *)error {
    NSLog(@"Error on identify API call: %@", [error localizedDescription]);
}
- (void)profileOk:(NSHTTPURLResponse *)result {
    NSLog(@"Success on profile API call. HTTP Status Code: %ld", result.statusCode);
}
- (void)profileErr:(NSError *)error {
    NSLog(@"Error on profile API call: %@", [error localizedDescription]);
}
- (void)targetingOk:(NSDictionary *)result {
    NSLog(@"Success on targeting API call: %@", result);
}
- (void)targetingErr:(NSError *)error {
    NSLog(@"Error on targeting API call: %@", [error localizedDescription]);
}
- (void)witnessOk:(NSHTTPURLResponse *)result {
    NSLog(@"Success on witness API call. HTTP Status Code: %ld", result.statusCode);
}
- (void)witnessErr:(NSError *)error {
    NSLog(@"Error on witness API call: %@", [error localizedDescription]);
}
@end
```

You can then configure an instance of the SDK integrating with an [Optable](https://optable.co/) DCN running at hostname `dcn.customer.com`, from a configured origin identified by slug `my-app` from your main `AppDelegate.m`, and point it to your delegate implementation as in the following example:

```objective-c
#import "OptabletSDKDelegate.h"
@import OptableSDK;

OptableSDK *OPTABLE = nil;
...
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...

    OptableSDKDelegate *delegate = [OptableSDKDelegate new];

    OptableConfig *config = [[OptableConfig alloc] initWithTenant: @"prebidtest" originSlug: @"ios-sdk"];
    config.host = @"prebidtest.cloud.optable.co";

    OPTABLE = [[OptableSDK alloc] initWithConfig: config];
    OPTABLE.delegate = delegate;

    ...
}
@end
```

You can call various SDK APIs on the instance as shown in the examples below. It's also possible to configure multiple instances of `OptableSDK` in order to connect to other (e.g., partner) DCNs and/or reference other configured application slug IDs. Note that the `insecure` flag should always be set to `NO` unless you are testing a local instance of the DCN yourself.

You can disable user agent `WKWebView` based auto-detection and provide your own value by setting the `useragent` parameter to a string value, similar to the Swift example.

### Identify API

To associate a user device with an authenticated identifier such as an Email address, or with other known IDs such as the Apple ID for Advertising (IDFA), or even your own vendor or app level `PPID`, you can call the `identify` API as follows:

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE identify: @{ @"e" : @"some.email@address.com", @"c" : @"new-custom.ABC" }
            error: &error];
```

Note that `error` will be set only in case of an internal SDK exception. Otherwise, any configured delegate `identifyOk` or `identifyErr` will be invoked to signal success or failure, respectively. Providing an empty `ppid` as in the above example simply will not send any `ppid`.

> :warning: **As of iOS 14.0**, Apple has introduced [additional restrictions on IDFA](https://developer.apple.com/app-store/user-privacy-and-data-use/) which will require prompting users to request permission to use IDFA. Therefore, if you intend to set `aaid` to `YES` in calls to `identify` on iOS 14.0 or above, you should expect that the SDK will automatically trigger a user prompt via the `AppTrackingTransparency` framework before it is permitted to send the IDFA value to your DCN. Additionally, we recommend that you ensure to configure the _Privacy - Tracking Usage Description_ attribute string in your application's `Info.plist`, as it enables you to customize some elements of the resulting user prompt.

### Profile API

To associate key value traits with the device, for eventual audience assembly, you can call the profile API as follows:

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE profileWithTraits: @{ @"gender": @"F", @"age": @38, @"hasAccount": @YES }
                        id: @"c:2", // NULL-able
                 neighbors: @[@"c:1", @"c:3"], // NULL-able
                     error: &error];
```

### Targeting API

To get the targeting key values associated by the configured DCN with the device in real-time, you can call the `targeting` API and expect that on success, the resulting keyvalues to be used for targeting will be sent in the `targetingOk` message to your delegate (see the example delegate implementation above):

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE targetingWithIds: @[@"c:1"] // NULL-able
                    error: &error];
```

#### Caching Targeting Data

The `targetingAndReturnError` method will automatically cache resulting key value data in client storage on success. You can subsequently retrieve the cached key value data as follows:

```objective-c
@import OptableSDK;
...
NSDictionary *cachedTargetingData = nil;
cachedTargetingData = [OPTABLE targetingFromCache];
if (cachedTargetingData != nil) {
  // cachedTargetingData! is an NSDictionary
}
```

You can also clear the locally cached targeting data:

```objective-c
@import OptableSDK;
...
[OPTABLE targetingClearCache];
```

Note that both `targetingFromCache` and `targetingClearCache` are synchronous.

### Witness API

To send real-time event data from the user's device to the DCN for eventual audience assembly, you can call the witness API as follows:

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE witnessWithEvent: @"GAMBannerViewController.loadBannerClicked"
               properties: @{ @"example": @"value" }
                    error: &error];
```

### Integrating GAM360

We can further extend the above `targetingOk` example delegate implementation to show an integration with a [Google Ad Manager 360](https://admanager.google.com/home/) ad server account, which uses the [Google Mobile Ads SDK's targeting capability](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/targeting).

We also extend the `targetingErr` delegate handler to load a GAM ad without targeting data in case of `targeting` API failure.

```objective-c
@implementation OptableSDKDelegate
  ...
- (void)targetingOk:(NSDictionary *)result {
    // Update the GAM banner view with result targeting keyvalues:
    DFPRequest *request = [DFPRequest request];
    request.customTargeting = result;
    [self.bannerView loadRequest:request];
}
- (void)targetingErr:(NSError *)error {
    // Load GAM banner even in case of targeting API error:
    DFPRequest *request = [DFPRequest request];
    [self.bannerView loadRequest: request];
}
  ...
@end
```

It's assumed in the above code snippet that `self.bannerView` is a pointer to a `DFPBannerView` instance which resides in your delegate and which has already been initialized and configured by a view controller.

### Identifying visitors arriving from Email newsletters

If you send Email newsletters that contain links to your application (e.g., universal links), then you may want to automatically _identify_ visitors that have clicked on any such links via their Email address.

-   [Check our url identify guide](identify-from-url.md)
