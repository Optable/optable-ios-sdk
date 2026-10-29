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
- (void)profileOk:(OptableTargeting *)result {
    NSLog(@"Success on profile API call: %@", result.targetingData);
}
- (void)profileErr:(NSError *)error {
    NSLog(@"Error on profile API call: %@", [error localizedDescription]);
}
- (void)targetingOk:(OptableTargeting *)result {
    NSLog(@"Success on targeting API call: %@", result.targetingData);
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

You can then create an instance of the SDK with an `OptableConfig` for your tenant and SDK source from your main `AppDelegate.m`, and point it to your delegate implementation as in the following example:

```objective-c
#import "OptableSDKDelegate.h"
@import OptableSDK;

OptableSDK *OPTABLE = nil;
...
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...

    OptableSDKDelegate *delegate = [OptableSDKDelegate new];

    OptableConfig *config = [[OptableConfig alloc] initWithTenant: @"acmeco" originSlug: @"my-app"];
    config.host = @"na.edge.optable.co";

    OPTABLE = [[OptableSDK alloc] initWithConfig: config];
    OPTABLE.delegate = delegate;

    ...
}
@end
```

`tenant` is your Optable tenant name (here `acmeco`), sent as the `t` query parameter, and `originSlug` is the slug of your SDK source (here `my-app`), sent as `o`. `host` is the regional service domain enabled for your account: `na.edge.optable.co` (North America, the default), `au.edge.optable.co` (Australia / New Zealand) or `eu.edge.optable.co` (Europe). Contact your account representative if you're unsure which regions you have.

You can call various SDK APIs on the instance as shown in the examples below. It's also possible to configure multiple instances of `OptableSDK` in order to connect to other (e.g., partner) DCNs and/or reference other configured application slug IDs. Note that the `insecure` flag should always be set to `NO` unless you are testing a local instance of the DCN yourself.

You can disable user agent `WKWebView` based auto-detection and provide your own value by setting the `customUserAgent` parameter to a string value, similar to the Swift example.

By default the SDK does not send an `Origin` HTTP header. If your DCN expects one, you can set the optional `origin` parameter to the origin you want your mobile traffic attributed to, and its value will be sent as the `Origin` header on every Optable API request (`identify`, `targeting`, `profile`, `witness`):

```objective-c
config.origin = @"https://www.acmeco.com";
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

Note that `error` will be set only in case of an internal SDK exception. Otherwise, any configured delegate `identifyOk` or `identifyErr` will be invoked to signal success or failure, respectively.

The SDK automatically adds the Apple ID for Advertising (IDFA) to the identifiers sent by `identify` and `targeting` whenever the user has authorized tracking. You don't need to pass it yourself. To turn this off, set `skipAdvertisingIdDetection` to `YES` on your `OptableConfig`.

> :warning: **IDFA requires user authorization**: Apple requires permission to use IDFA via the [AppTrackingTransparency](https://developer.apple.com/app-store/user-privacy-and-data-use/) framework. The SDK only reads the current authorization status and **does not** show the ATT prompt itself. Your application must request authorization, for example with `[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:]`, and must set the _Privacy - Tracking Usage Description_ (`NSUserTrackingUsageDescription`) string in its `Info.plist`. Until the user authorizes tracking, no IDFA is sent.

#### Normalization before hashing

The SDK computes the SHA-256 hash of email addresses and phone numbers on the device, so they are **not** sent in plain text.

Before hashing, the SDK removes all whitespace and lowercases the value. It does **not** otherwise reformat it. In particular, phone numbers are not converted to [E.164](https://en.wikipedia.org/wiki/E.164), so `@"+1 555-123-4567"`, `@"+15551234567"` and `@"5551234567"` produce three different hashes. Pass phone numbers in E.164 format (for example, `@"+15551234567"`) so that they match the identifiers in your DCN.

#### Already-hashed identifiers

If you already have the SHA-256 hash of an email address or phone number, for example from your backend, pass it with the `OptableSDKIdentifierType_HEM` or `OptableSDKIdentifierType_HashedPhoneNumber` type so that the SDK doesn't hash it a second time:

```objective-c
NSArray *ids = @[
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_HEM value:@"<sha256 of the normalized email address>"],
    [OptableSDKIdentifier identifierWithType:OptableSDKIdentifierType_HashedPhoneNumber value:@"<sha256 of the E.164 phone number>"],
];

[OPTABLE identify: ids error: &error];
```

The value must be a 64-character hexadecimal SHA-256 digest, computed with the same normalization the SDK uses (whitespace removed, lowercased). The SDK lowercases the digest but does not hash it again. Values that aren't a valid SHA-256 digest are dropped and not sent, so a plain-text email address or phone number passed by mistake never leaves the device.

Do not pass a hash with the `OptableSDKIdentifierType_EmailAddress` or `OptableSDKIdentifierType_PhoneNumber` types: those types always hash their value, so the DCN would receive a hash of the hash. Already-hashed identifiers work the same way with `targeting`.

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

On success, the delegate's `profileOk` receives the updated `OptableTargeting` for the device, which is also cached for `targetingFromCache`.

> :warning: Unlike `identify` and `targeting`, `id` and `neighbors` are plain type-prefixed strings (such as `c:2`) that are sent exactly as given: the SDK does **not** normalize or hash them. Never pass a plain-text email address or phone number here; hash it first.

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

The `targeting:error:` and `targetingWithIds:hids:error:` methods automatically cache the resulting `OptableTargeting` in client storage on success. You can subsequently retrieve the cached key value data as follows:

```objective-c
@import OptableSDK;
...
OptableTargeting *cachedOptableTargeting = [OPTABLE targetingFromCache];
if (cachedOptableTargeting != nil) {
  // cachedOptableTargeting is an OptableTargeting, the same type passed to targetingOk
}
```

You can also clear the locally cached targeting data:

```objective-c
@import OptableSDK;
...
[OPTABLE targetingClearCache];
```

Note that both `targetingFromCache` and `targetingClearCache` are synchronous.

##### Cache Expiry

Cached targeting data expires 24 hours after it was fetched. Once an entry has expired, `targetingFromCache` reports it as absent by returning `nil`, and clears it from client storage. Call the targeting API again to refresh it.

You can change the lifetime by setting the `cacheTTL` property, expressed in seconds:

```objective-c
@import OptableSDK;
...
config.cacheTTL = 60 * 60; // expire cached targeting data after one hour
```

The default is `OptableConfig.defaultCacheTTL`, which is 24 hours. Setting `cacheTTL` to `0` effectively disables the cache, since every entry is then already expired by the time it is read.

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
- (void)targetingOk:(OptableTargeting *)result {
    // Update the GAM banner view with result targeting keyvalues:
    GAMRequest *request = [GAMRequest request];
    request.customTargeting = result.gamTargetingKeywords;
    [self.bannerView loadRequest:request];
}
- (void)targetingErr:(NSError *)error {
    // Load GAM banner even in case of targeting API error:
    GAMRequest *request = [GAMRequest request];
    [self.bannerView loadRequest:request];
}
  ...
@end
```

It's assumed in the above code snippet that `self.bannerView` is a pointer to a `GAMBannerView` instance which resides in your delegate and which has already been initialized and configured by a view controller. Delegate methods are always called on the main thread, so the ad can be loaded directly from them.

### Identifying visitors arriving from Email newsletters

If you send Email newsletters that contain links to your application (e.g., universal links), then you may want to automatically _identify_ visitors that have clicked on any such links via their Email address.

- [Check our url identify guide](identify-from-url.md)
