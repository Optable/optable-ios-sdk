# Optable iOS SDK [![CircleCI](https://circleci.com/gh/Optable/optable-ios-sdk.svg?style=shield&circle-token=08842d5bffbe92f278b666f51f306076201e2839)](https://app.circleci.com/pipelines/github/Optable/optable-ios-sdk)

Swift SDK for integrating with optable-sandbox from an iOS application.

It's possible to use the SDK functionality from either a Swift or Objective-C iOS application.

## Contents

- [Installing](#installing)
- [Using (Swift)](#using--swift-)
  - [Identify API](#identify-api)
  - [Targeting API](#targeting-api)
  - [Witness API](#witness-api)
  - [Integrating GAM360](#integrating-gam360)
- [Using (Objective-C)](#using--objective-c-)
  - [Identify API](#identify-api-1)
  - [Targeting API](#targeting-api-1)
  - [Witness API](#witness-api-1)
  - [Integrating GAM360](#integrating-gam360-1)
- [Demo Applications](#demo-applications)
  - [Building](#building)

## Installing

This SDK can be installed via the [CocoaPods](https://cocoapods.org/) dependency manager. To install the latest [release](https://github.com/Optable/optable-ios-sdk/releases), you need to source the [optable-cocoapods](https://github.com/Optable/optable-cocoapods) private repository as well as the `OptableSDK` pod from your `Podfile`:

```ruby
platform :ios, '13.0'

source 'git@github.com:Optable/optable-cocoapods.git'
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
pod 'OptableSDK', '0.2.0'
```

## Using (Swift)

To configure an instance of the SDK integrating with an [Optable](https://optable.co/) sandbox running at hostname `sandbox.customer.com`, from a configured Swift application origin identified by slug `my-app`, you simply create an instance of the `OptableSDK` class through which you can communicate to the sandbox. For example, from your `AppDelegate`:

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
        OPTABLE = OptableSDK(host: "sandbox.customer.com", app: "my-app")
        ...
        return true
    }
    ...
}
```

Note that while the `OPTABLE` variable is global, we initialize it with an instance of `OptableSDK` in the `application()` method which runs at app launch, and not at the time it is declared. This is done because Swift's lazy-loading otherwise delays initialization to the first use of the variable. Both approaches work, though forcing early initialization allows the SDK to configure itself early. In particular, as part of its internal configuration the SDK will attempt to read the User-Agent string exposed by WebView and, since this is an asynchronous operation, it is best done as early as possible in the application lifecycle.

You can call various SDK APIs on the instance as shown in the examples below. It's also possible to configure multiple instances of `OptableSDK` in order to connect to other (e.g., partner) sandboxes and/or reference other configured application slug IDs.

Note that all SDK communication with Optable sandboxes is done over TLS. The only exception to this is if you instantiate the `OptableSDK` class with a third optional boolean parameter, `insecure`, set to `true`. For example:

```swift
OPTABLE = OptableSDK(host: "sandbox.customer.com", app: "my-app", insecure: true)
```

However, since production sandboxes only listen to TLS traffic, the above is really only useful for developers of `optable-sandbox` running the sandbox locally for testing.

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

The SDK `identify()` method will asynchronously connect to the configured sandbox and send IDs for resolution. The provided callback can be used to understand successful completion or errors.

> :warning: **Client-Side Email Hashing**: The SDK will compute the SHA-256 hash of the Email address on the client-side and send the hashed value to the sandbox. The Email address is **not** sent by the device in plain text.

Since the `sendIDFA` value provided to `identify()` via the `aaid` (Apple Advertising ID or IDFA) boolean parameter is `true`, the SDK will attempt to fetch and send the Apple IDFA in the call to `identify` too, unless the user has turned on "Limit ad tracking" in their iOS device privacy settings.

> :warning: **As of iOS 14.0**, Apple has introduced [additional restrictions on IDFA](https://developer.apple.com/app-store/user-privacy-and-data-use/) which will require prompting users to request permission to use IDFA. Therefore, if you intend to set `aaid` to `true` in calls to `identify()` on iOS 14.0 or above, you should expect that the SDK will automatically trigger a user prompt via the `AppTrackingTransparency` framework before it is permitted to send the IDFA value to your sandbox. Additionally, we recommend that you ensure to configure the _Privacy - Tracking Usage Description_ attribute string in your application's `Info.plist`, as it enables you to customize some elements of the resulting user prompt.

The frequency of invocation of `identify` is up to you, however for optimal identity resolution we recommended to call the `identify()` method on your SDK instance every time you authenticate a user, as well as periodically, such as for example once every 15 to 60 minutes while the application is being actively used and an internet connection is available.

### Targeting API

To get the targeting key values associated by the configured sandbox with the device in real-time, you can call the `targeting` API as follows:

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

### Witness API

To send real-time event data from the user's device to the sandbox for eventual audience assembly, you can call the witness API as follows:

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

Note that event properties are of type `NSDictionary` and should consist only of string keyvalue pairs.

### Integrating GAM360

We can further extend the above `targeting` example to show an integration with a [Google Ad Manager 360](https://admanager.google.com/home/) ad server account:

```swift
import GoogleMobileAds
...

do {
    try OPTABLE!.targeting() { result in
        switch result {
        case .success(let keyvalues):
            // We assume bannerView is a DFPBannerView() instance that has already been
            // initialized and added to our view:
            bannerView.adUnitID = "/12345/some-ad-unit-id/in-your-gam360-account"

            // Build GAM ad request with key values and load banner:
            let req = DFPRequest()
            req.customTargeting = keyvalues as! [String: Any]
            bannerView.load(req)

        case .failure(let error):
            // handle targeting API failure in `error`
        }
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
    NSLog(@"Success on /identify API call. HTTP Status Code: %ld", result.statusCode);
}
- (void)identifyErr:(NSError *)error {
    NSLog(@"Error on /identify API call: %@", [error localizedDescription]);
}
- (void)targetingOk:(NSDictionary *)result {
    NSLog(@"Success on /targeting API call: %@", result);
}
- (void)targetingErr:(NSError *)error {
    NSLog(@"Error on /targeting API call: %@", [error localizedDescription]);
}
- (void)witnessOk:(NSHTTPURLResponse *)result {
    NSLog(@"Success on /witness API call. HTTP Status Code: %ld", result.statusCode);
}
- (void)witnessErr:(NSError *)error {
    NSLog(@"Error on /witness API call: %@", [error localizedDescription]);
}
@end
```

You can then configure an instance of the SDK integrating with an [Optable](https://optable.co/) sandbox running at hostname `sandbox.customer.com`, from a configured origin identified by slug `my-app` from your main `AppDelegate.m`, and point it to your delegate implementation as in the following example:

```objective-c
#import "OptabletSDKDelegate.h"
@import OptableSDK;

OptableSDK *OPTABLE = nil;
...
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ...
    OPTABLE = [[OptableSDK alloc] initWithHost: @"sandbox.optable.co"
                                  app: @"ios-sdk-demo"
                                  insecure: NO];
    OptableSDKDelegate *delegate = [[OptableSDKDelegate alloc] init];
    OPTABLE.delegate = delegate;
  ...
}
@end
```

You can call various SDK APIs on the instance as shown in the examples below. It's also possible to configure multiple instances of `OptableSDK` in order to connect to other (e.g., partner) sandboxes and/or reference other configured application slug IDs. Note that the `insecure` flag should always be set to `NO` unless you are testing a local instance of the `optable-sandbox` yourself.

### Identify API

To associate a user device with an authenticated identifier such as an Email address, or with other known IDs such as the Apple ID for Advertising (IDFA), or even your own vendor or app level `PPID`, you can call the `identify` API as follows:

```objective-c
@import OptableSDK;
...

NSError *error = nil;
[OPTABLE identify :@"some.email@address.com" aaid:YES ppid:@"" error:&error];
```

Note that `error` will be set only in case of an internal SDK exception. Otherwise, any configured delegate `identifyOk` or `identifyErr` will be invoked to signal success or failure, respectively. Providing an empty `ppid` as in the above example simply will not send any `ppid`.

> :warning: **As of iOS 14.0**, Apple has introduced [additional restrictions on IDFA](https://developer.apple.com/app-store/user-privacy-and-data-use/) which will require prompting users to request permission to use IDFA. Therefore, if you intend to set `aaid` to `YES` in calls to `identify` on iOS 14.0 or above, you should expect that the SDK will automatically trigger a user prompt via the `AppTrackingTransparency` framework before it is permitted to send the IDFA value to your sandbox. Additionally, we recommend that you ensure to configure the _Privacy - Tracking Usage Description_ attribute string in your application's `Info.plist`, as it enables you to customize some elements of the resulting user prompt.

It's also possible to send only an Email ID hash or a custom PPID by using the lower-level `identify` method which accepts a list of pre-constructed identifiers, for example:

```objective-c
@import OptableSDK;
...

NSError *error = nil;
[OPTABLE identify :@[[OPTABLE cid:@"xyz123abc"],
                     [OPTABLE eid:@"some.email@address.com" ]] error:&error];
```

### Targeting API

To get the targeting key values associated by the configured sandbox with the device in real-time, you can call the `targeting` API and expect that on success, the resulting keyvalues to be used for targeting will be sent in the `targetingOk` message to your delegate (see the example delegate implementation above):

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE targetingAndReturnError:&error];
```

### Witness API

To send real-time event data from the user's device to the sandbox for eventual audience assembly, you can call the witness API as follows:

```objective-c
@import OptableSDK;
...
NSError *error = nil;
[OPTABLE witness:@"example.event.type" properties:@{ @"example": @"value" } error:&error];
```

### Integrating GAM360

We can further extend the above `targetingOk` example delegate implementation to show an integration with a [Google Ad Manager 360](https://admanager.google.com/home/) ad server account, which uses the [Google Mobile Ads SDK's targeting capability](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/targeting):

```objective-c
@implementation OptableSDKDelegate
  ...
- (void)targetingOk:(NSDictionary *)result {
    // Update the GAM banner view with result targeting keyvalues:
    DFPRequest *request = [DFPRequest request];
    request.customTargeting = result;
    [self.bannerView loadRequest:request];
}
  ...
@end
```

It's assumed in the above code snippet that `self.bannerView` is a pointer to a `DFPBannerView` instance which resides in your delegate and which has already been initialized and configured by a view controller.

## Demo Applications

The Swift and Objective-C demo applications show a working example of `identify` , `targeting`, and `witness` APIs, as well as an integration with the [Google Ad Manager 360](https://admanager.google.com/home/) ad server, enabling the targeting of ads served by GAM360 to audiences activated in the [Optable](https://optable.co/) sandbox.

By default, the demo applications will connect to the [Optable](https://optable.co/) demo sandbox at `sandbox.optable.co` and reference application slug `android-sdk-demo`. The demo apps depend on the [GAM Mobile Ads SDK for iOS](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start) and load ads from a GAM360 account operated by [Optable](https://optable.co/).

### Building

[Cocoapods](https://cocoapods.org/) is required to build the `demo-ios-swift` and `demo-ios-objc` applications. After cloning the repo, simply `cd` into either of the two demo app directories and run:

```
pod install
```

Then open the generated `demo-ios-swift.xcworkspace` or `demo-ios-objc.xcworkspace` in [Xcode](https://developer.apple.com/xcode/), and build and run from there.
