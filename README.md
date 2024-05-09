# Optable iOS SDK [![CircleCI](https://circleci.com/gh/Optable/optable-ios-sdk.svg?style=shield&circle-token=08842d5bffbe92f278b666f51f306076201e2839)](https://app.circleci.com/pipelines/github/Optable/optable-ios-sdk)

Swift SDK for integrating with an [Optable Data Connectivity Node (DCN)](https://docs.optable.co) from an iOS application.

You can use the SDK functionality from either a Swift or Objective-C iOS application.

## Contents

- [Installing](#installing)
- [Using (Swift)](#using-swift)
  - [Identify API](#identify-api)
  - [Profile API](#profile-api)
  - [Targeting API](#targeting-api)
  - [Witness API](#witness-api)
  - [Integrating GAM360](#integrating-gam360)
- [Using (Objective-C)](#using-objective-c)
  - [Identify API](#identify-api-1)
  - [Profile API](#profile-api-1)
  - [Targeting API](#targeting-api-1)
  - [Witness API](#witness-api-1)
  - [Integrating GAM360](#integrating-gam360-1)
- [Identifying visitors arriving from Email newsletters](#identifying-visitors-arriving-from-email-newsletters)
  - [Insert oeid into your Email newsletter template](#insert-oeid-into-your-email-newsletter-template)
  - [Capture clicks on universal links in your application](#capture-clicks-on-universal-links-in-your-application)
  - [Call tryIdentifyFromURL SDK API](#call-tryidentifyfromurl-sdk-api)
- [Demo Applications](#demo-applications)
  - [Building](#building)

## Installing

The SDK can be installed using either the [Swift Package Manager](https://www.swift.org/package-manager/) or the [CocoaPods](https://cocoapods.org) dependency manager.

### Swift Package Manager

You can add this SDK _Package_ to your project. The manifest file is [Package.swift](https://github.com/Optable/optable-ios-sdk/blob/master/Package.swift)

### CocoaPods

This SDK can be installed via the [CocoaPods](https://cocoapods.org/) dependency manager. To install the latest [release](https://github.com/Optable/optable-ios-sdk/releases), you need to source the [public cocoapods](https://cdn.cocoapods.org/) repository as well as the `OptableSDK` pod from your `Podfile`:

```ruby
platform :ios, '13.0'

source 'https://cdn.cocoapods.org/'
...

target 'YourProject' do
  use_frameworks!

  pod 'OptableSDK'
  ...
end
```

You can then run `pod install` to download all of your dependencies and prepare your project `xcworkspace`.

If you would like to reference a specific [release](https://github.com/Optable/optable-ios-sdk/releases), simply append it to the referenced pod. For example:

```ruby
pod 'OptableSDK', '0.8.2'
```

## Using (Swift)

To configure an instance of the SDK integrating with an [Optable](https://optable.co/) DCN running at hostname `dcn.customer.com`, from a configured Swift application origin identified by slug `my-app`, you simply create an instance of the `OptableSDK` class through which you can communicate to the DCN. For example, from your `AppDelegate`:

```swift
import OptableSDK
import UIKit
...

var OPTABLE: OptableSDK?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ...
        OPTABLE = OptableSDK(host: "dcn.customer.com", app: "my-app")
        ...
        return true
    }
    ...
}
```

Note that while the `OPTABLE` variable is global, we initialize it with an instance of `OptableSDK` in the `application()` method which runs at app launch, and not at the time it is declared. This is done because Swift's lazy-loading otherwise delays initialization to the first use of the variable. Both approaches work, though forcing early initialization allows the SDK to configure itself early. In particular, as part of its internal configuration the SDK will attempt to read the User-Agent string exposed by WebView and, since this is an asynchronous operation, it is best done as early as possible in the application lifecycle.

You can call various SDK APIs on the instance as shown in the examples below. It's also possible to configure multiple instances of `OptableSDK` in order to connect to other (e.g., partner) DCNs and/or reference other configured application slug IDs.

Note that all SDK communication with Optable DCNs is done over TLS. The only exception to this is if you instantiate the `OptableSDK` class with a third optional boolean parameter, `insecure`, set to `true`. For example:

```swift
OPTABLE = OptableSDK(host: "dcn.customer.com", app: "my-app", insecure: true)
```

Note that production DCNs only listen to TLS traffic. The `insecure: true` option is meant to be used by Optable developers running the DCN locally for testing.

By default, the SDK detects the application user agent by sniffing `navigator.userAgent` from a `WKWebView`. The resulting user agent string is sent to your DCN for analytics purposes. To disable this behavior, you can provide an optional fourth string parameter, `useragent`, which allows you to set whatever user agent string you would like to send instead. For example:

```swift
OPTABLE = OptableSDK(host: "dcn.customer.com", app: "my-app", insecure: false, useragent: "custom-ua")
```

The default value of `nil` for the `useragent` parameter enables the `WKWebView` auto-detection behavior.

### Identify API

To associate a user device with an authenticated identifier such as an Email address, or with other known IDs such as the Apple ID for Advertising (IDFA), or even your own vendor or app level `PPID`, you can call the `identify` API as follows:

```swift
let emailString = "some.email@address.com"
let sendIDFA = true

do {
    try OPTABLE!.identify(email: emailString, aaid: sendIDFA) { result in
        switch (result) {
        case .success(let response):
            // identify API success, response.statusCode is HTTP response status 200
        case .failure(let error):
            // handle identify API failure in `error`
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

The SDK `identify()` method will asynchronously connect to the configured DCN and send IDs for resolution. The provided callback can be used to understand successful completion or errors.

> :warning: **Client-Side Email Hashing**: The SDK will compute the SHA-256 hash of the Email address on the client-side and send the hashed value to the DCN. The Email address is **not** sent by the device in plain text.

Since the `sendIDFA` value provided to `identify()` via the `aaid` (Apple Advertising ID or IDFA) boolean parameter is `true`, the SDK will attempt to fetch and send the Apple IDFA in the call to `identify` too, unless the user has turned on "Limit ad tracking" in their iOS device privacy settings.

> :warning: **As of iOS 14.0**, Apple has introduced [additional restrictions on IDFA](https://developer.apple.com/app-store/user-privacy-and-data-use/) which will require prompting users to request permission to use IDFA. Therefore, if you intend to set `aaid` to `true` in calls to `identify()` on iOS 14.0 or above, you should expect that the SDK will automatically trigger a user prompt via the `AppTrackingTransparency` framework before it is permitted to send the IDFA value to your DCN. Additionally, we recommend that you ensure to configure the _Privacy - Tracking Usage Description_ attribute string in your application's `Info.plist`, as it enables you to customize some elements of the resulting user prompt.

The frequency of invocation of `identify` is up to you, however for optimal identity resolution we recommended to call the `identify()` method on your SDK instance every time you authenticate a user, as well as periodically, such as for example once every 15 to 60 minutes while the application is being actively used and an internet connection is available.

### Profile API

To associate key value traits with the device, for eventual audience assembly, you can call the profile API as follows:

```swift
do {
    try OPTABLE!.profile(traits: ["gender": "F", "age": 38, "hasAccount": true]) { result in
        switch (result) {
        case .success(let response):
            // profile API success, response.statusCode is HTTP response status 200
        case .failure(let error):
            // handle profile API failure in `error`
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

The specified traits are associated with the user's device and can be matched during audience assembly.

Note that the traits are of type `NSDictionary` and should consist of key value pairs, where the keys are strings and the values are either strings, numbers, or booleans.

### Targeting API

To get the targeting key values associated by the configured DCN with the device in real-time, you can call the `targeting` API as follows:

```swift
do {
    try OPTABLE!.targeting() { result in
        switch result {
        case .success(let keyvalues):
            // keyvalues is an NSDictionary containing targeting key-values that can be
            // passed on to ad servers or other decisioning systems

        case .failure(let error):
            // handle targeting API failure in `error`
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

On success, the resulting key values are typically sent as part of a subsequent ad call. Therefore we recommend that you either call `targeting()` before each ad call, or in parallel periodically, caching the resulting key values which you then provide in ad calls.

#### Caching Targeting Data

The `targeting` API will automatically cache resulting key value data in client storage on success. You can subsequently retrieve the cached key value data as follows:

```swift
let cachedTargetingData = OPTABLE!.targetingFromCache()
if (cachedTargetingData != nil) {
  // cachedTargetingData! is an NSDictionary which you can cast as! [String: Any]
}
```

You can also clear the locally cached targeting data:

```swift
OPTABLE!.targetingClearCache()
```

Note that both `targetingFromCache()` and `targetingClearCache()` are synchronous.

### Witness API

To send real-time event data from the user's device to the DCN for eventual audience assembly, you can call the witness API as follows:

```swift
do {
    try OPTABLE!.witness(event: "example.event.type",
                         properties: ["example": "value"]) { result in
        switch (result) {
        case .success(let response):
            // witness API success, response.statusCode is HTTP response status 200
        case .failure(let error):
            // handle witness API failure in `error`
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

The specified event type and properties are associated with the logged event and which can be used for matching during audience assembly.

Note that event properties are of type `NSDictionary` and should consist of key value pairs, where the keys are strings and the values are either strings, numbers, or booleans.

### Integrating GAM360

We can further extend the above `targeting` example to show an integration with a [Google Ad Manager 360](https://admanager.google.com/home/) ad server account.

It's suggested to load the GAM banner view with an ad even when the call to your DCN `targeting()` method results in failure:

```swift
import GoogleMobileAds
...

do {
    try OPTABLE!.targeting() { result in
        var tdata: NSDictionary = [:]

        switch result {
        case .success(let keyvalues):
            // Save targeting data in `tdata`:
            tdata = keyvalues

        case .failure(let error):
            // handle targeting API failure in `error`
        }

        // We assume bannerView is a DFPBannerView() instance that has already been
        // initialized and added to our view:
        bannerView.adUnitID = "/12345/some-ad-unit-id/in-your-gam360-account"

        // Build GAM ad request with key values and load banner:
        let req = DFPRequest()
        req.customTargeting = tdata as! [String: Any]
        bannerView.load(req)
    }
} catch {
    // handle thrown exception in `error`
}
```

A working example is available in the demo application.

## Using (Objective-C)

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
    OPTABLE = [[OptableSDK alloc] initWithHost: @"dcn.optable.co"
                                  app: @"ios-sdk-demo"
                                  insecure: NO
                                  useragent: nil];
    OptableSDKDelegate *delegate = [[OptableSDKDelegate alloc] init];
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
[OPTABLE identify :@"some.email@address.com" aaid:YES ppid:@"" error:&error];
```

Note that `error` will be set only in case of an internal SDK exception. Otherwise, any configured delegate `identifyOk` or `identifyErr` will be invoked to signal success or failure, respectively. Providing an empty `ppid` as in the above example simply will not send any `ppid`.

> :warning: **As of iOS 14.0**, Apple has introduced [additional restrictions on IDFA](https://developer.apple.com/app-store/user-privacy-and-data-use/) which will require prompting users to request permission to use IDFA. Therefore, if you intend to set `aaid` to `YES` in calls to `identify` on iOS 14.0 or above, you should expect that the SDK will automatically trigger a user prompt via the `AppTrackingTransparency` framework before it is permitted to send the IDFA value to your DCN. Additionally, we recommend that you ensure to configure the _Privacy - Tracking Usage Description_ attribute string in your application's `Info.plist`, as it enables you to customize some elements of the resulting user prompt.

It's also possible to send only an Email ID hash or a custom PPID by using the lower-level `identify` method which accepts a list of pre-constructed identifiers, for example:

```objective-c
@import OptableSDK;
...

NSError *error = nil;
[OPTABLE identify :@[[OPTABLE cid:@"xyz123abc"],
                     [OPTABLE eid:@"some.email@address.com" ]] error:&error];
```

### Profile API

To associate key value traits with the device, for eventual audience assembly, you can call the profile API as follows:

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE profileWithTraits:@{ @"gender": @"F", @"age": @38, @"hasAccount": @YES } error:&error];
```

### Targeting API

To get the targeting key values associated by the configured DCN with the device in real-time, you can call the `targeting` API and expect that on success, the resulting keyvalues to be used for targeting will be sent in the `targetingOk` message to your delegate (see the example delegate implementation above):

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE targetingAndReturnError:&error];
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
[OPTABLE witness:@"example.event.type" properties:@{ @"example": @"value", @"example2": @123, @"example3": @NO } error:&error];
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

## Identifying visitors arriving from Email newsletters

If you send Email newsletters that contain links to your application (e.g., universal links), then you may want to automatically _identify_ visitors that have clicked on any such links via their Email address.

### Insert oeid into your Email newsletter template

To enable automatic identification of visitors originating from your Email newsletter, you first need to include an **oeid** parameter in the query string of all links to your website in your Email newsletter template. The value of the **oeid** parameter should be set to the SHA256 hash of the lowercased Email address of the recipient. For example, if you are using [Braze](https://www.braze.com/) to send your newsletters, you can easily encode the SHA256 hash value of the recipient's Email address by setting the **oeid** parameter in the query string of any links to your application as follows:

```
oeid={{${email_address} | downcase | sha2}}
```

The above example uses various personalization tags as documented in [Braze's user guide](https://www.braze.com/docs/user_guide/personalization_and_dynamic_content/) to dynamically insert the required data into an **oeid** parameter, all of which should make up a _part_ of the destination URL in your template.

### Capture clicks on universal links in your application

In order for your application to open on devices where it is installed when a link to your domain is clicked, you need to [configure and prepare your application to handle universal links](https://developer.apple.com/ios/universal-links/) first.

### Call tryIdentifyFromURL SDK API

When iOS launches your app after a user taps a universal link, you receive an `NSUserActivity` object with an `activityType` value of `NSUserActivityTypeBrowsingWeb`. The activity object's `webpageURL` property contains the URL that the user is accessing. You can then pass it to the SDK's `tryIdentifyFromURL()` API which will automatically look for `oeid` in the query string of the URL and call `identify` with its value if found.

#### Swift

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
  if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
    let url = userActivity.webpageURL!
    try OPTABLE!.tryIdentifyFromURL(url)
  }
  ...
}
```

#### Objective-C

```objective-c
-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {

  if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
    NSURL *url = userActivity.webpageURL;
    NSError *error = nil;
    [OPTABLE tryIdentifyFromURL :url.absoluteString error:&error];
    ...
  }
  ...

}
```

## Demo Applications

The Swift and Objective-C demo applications show a working example of `identify` , `targeting`, and `witness` APIs, as well as an integration with the [Google Ad Manager 360](https://admanager.google.com/home/) ad server, enabling the targeting of ads served by GAM360 to audiences activated in the [Optable](https://optable.co/) DCN.

By default, the demo applications will connect to the [Optable](https://optable.co/) demo DCN at `sandbox.optable.co` and reference application slug `ios-sdk-demo`. The demo apps depend on the [GAM Mobile Ads SDK for iOS](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start) and load ads from a GAM360 account operated by [Optable](https://optable.co/).

When connecting to a local DCN, you must drag and drop the SSL certificate file into the iPhone simulator which is obtained with the following command:
`gcloud --project optable-platform-dev secrets versions access latest --secret local-ca-crt > local-ca.cer`

### Building

[Cocoapods](https://cocoapods.org/) is required to build the `demo-ios-swift` and `demo-ios-objc` applications. After cloning the repo, simply `cd` into either of the two demo app directories and run:

```
pod install
```

Then open the generated `demo-ios-swift.xcworkspace` or `demo-ios-objc.xcworkspace` in [Xcode](https://developer.apple.com/xcode/), and build and run from there.
