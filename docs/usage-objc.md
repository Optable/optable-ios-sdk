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

You can disable user agent `WKWebView` based auto-detection and provide your own value by setting the `customUserAgent` parameter to a string value, similar to the Swift example.

By default the SDK does not send an `Origin` HTTP header. If your DCN expects one, you can set the optional `origin` parameter, and its value will be sent as the `Origin` header on every Optable API request (`identify`, `targeting`, `profile`, `witness`):

```objective-c
config.origin = @"https://dcn.customer.com";
```

### Identify API

To associate a user device with an authenticated identifier such as an Email address, or with other known IDs such as the Apple ID for Advertising (IDFA), or even your own vendor or app level `PPID`, you can call the `identify` API as follows:

```objective-c
@import OptableSDK;
...
NSError *error = nil;
NSArray *ids = @[
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_EmailAddress value:@"test@test.test"],
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_PhoneNumber value:@"+1234567890"],
];

[OPTABLE identify: ids error: &error];
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
[OPTABLE targeting: @[
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_EmailAddress value:@"test@test.test"]
]
             error: &error];
```

You may optionally supply hint identifiers (`hids`) which are forwarded as resolver-specific `hid` parameters, used by integrations such as ID5 Mobile In-App:

```objective-c
[OPTABLE targetingWithIds: @[
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_EmailAddress value:@"test@test.test"]
]
                     hids: @[
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_PhoneNumber value:@"+1234567890"]
]
                    error: &error];
```

> :information_source: For more details on `hid` parameters, including the supported identifier types, check:
> [Optable Real-Time API Integrations Guide > Resolver Specific Parameters > ID5 Mobile In-App](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/resolver-specific-parameters#id5-mobile-in-app)

#### Resolver-Specific Parameters

On every targeting call the SDK automatically attaches the parameters required by resolver-specific integrations such as ID5 Mobile In-App:

- `bundle`: the application's bundle identifier.
- `ver`: the application's version (`CFBundleShortVersionString`).
- `ua`: the user agent of the device's default browser, detected asynchronously via `WKWebView` at SDK initialization. If a targeting call happens before detection completes, the parameter is omitted; set the `customUserAgent` configuration parameter to guarantee it is always present.
- `id5_signature`: the ID5 signature cached from a previous targeting response, when available.

When a targeting response contains an ID5 EID, the SDK extracts the associated signature and caches it in client storage. The cached signature persists across app restarts, is sent as `id5_signature` on subsequent targeting calls to improve ID5 resolve rates, and is removed by `targetingClearCache`. A targeting response that contains no ID5 signature removes any previously cached one, so the SDK never sends a stale signature.

In addition, unless `skipAdvertisingIdDetection` is set in the configuration, the device IDFA is automatically added to both `ids` and `hids` when ad tracking is authorized by the user.

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

- [Check our url identify guide](identify-from-url.md)
