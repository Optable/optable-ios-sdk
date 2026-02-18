## Usage (Swift)

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
        let config = OptableConfig(
            tenant: "dcn.customer.com",
            originSlug: "my-app",
            host: "dcn.customer.com"
        )
        OPTABLE = OptableSDK(config: config)
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
let config = OptableConfig(..., insecure: true)
OPTABLE = OptableSDK(config: config)
```

Note that production DCNs only listen to TLS traffic. The `insecure: true` option is meant to be used by Optable developers running the DCN locally for testing.

By default, the SDK detects the application user agent by sniffing `navigator.userAgent` from a `WKWebView`. The resulting user agent string is sent to your DCN for analytics purposes. To disable this behavior, you can provide an optional string parameter, `useragent`, which allows you to set whatever user agent string you would like to send instead. For example:

```swift
let config = OptableConfig(..., useragent: "custom-ua")
OPTABLE = OptableSDK(config: config)
```

The default value of `nil` for the `useragent` parameter enables the `WKWebView` auto-detection behavior.

### Identify API

To associate a user device with an authenticated identifier such as an Email address, or with other known IDs such as the Apple ID for Advertising (IDFA), or even your own vendor or app level `PPID`, you can call the `identify` API as follows:

```swift
do {
    let ids: [OptableIdentifier] = [
        .emailAddress("some.email@address.com"),
        .phoneNumber("+1234567890")
    ]
    try OPTABLE!.identify(ids) { result in
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

> :warning: **Client-Side Hashing**: The SDK will compute the SHA-256 hash of the email address and phone number on the client-side and send the hashed value to the DCN.
>
> The email address / phone number is **not** sent by the device in plain text.

Since the `sendIDFA` value provided to `identify()` via the `aaid` (Apple Advertising ID or IDFA) boolean parameter is `true`, the SDK will attempt to fetch and send the Apple IDFA in the call to `identify` too, unless the user has turned on "Limit ad tracking" in their iOS device privacy settings.

> :warning: **As of iOS 14.0**, Apple has introduced [additional restrictions on IDFA](https://developer.apple.com/app-store/user-privacy-and-data-use/) which will require prompting users to request permission to use IDFA. Therefore, if you intend to set `aaid` to `true` in calls to `identify()` on iOS 14.0 or above, you should expect that the SDK will automatically trigger a user prompt via the `AppTrackingTransparency` framework before it is permitted to send the IDFA value to your DCN. Additionally, we recommend that you ensure to configure the _Privacy - Tracking Usage Description_ attribute string in your application's `Info.plist`, as it enables you to customize some elements of the resulting user prompt.

The frequency of invocation of `identify` is up to you, however for optimal identity resolution we recommended to call the `identify()` method on your SDK instance every time you authenticate a user, as well as periodically, such as for example once every 15 to 60 minutes while the application is being actively used and an internet connection is available.

### Profile API

> :information_source: For more info check:
> [Optable Real-Time API Endpoints > Profile](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/profile)

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

> :information_source: For more info check:
> [Optable Real-Time API Endpoints > Targeting](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/targeting)

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

> :information_source: For more info check:
> [Optable Real-Time API Endpoints > Witness](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/)

To send real-time event data from the user's device to the DCN for eventual audience assembly, you can call the witness API as follows:

```swift
do {
    try OPTABLE!.witness(event: "example.event.type", properties: ["example": "value"]) { result in
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

### Identifying visitors arriving from Email newsletters

If you send Email newsletters that contain links to your application (e.g., universal links), then you may want to automatically _identify_ visitors that have clicked on any such links via their Email address.

- [Check our url identify guide](identify-from-url.md)
