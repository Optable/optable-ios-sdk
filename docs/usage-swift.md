## Usage (Swift)

To configure the SDK, create an instance of the `OptableSDK` class with an `OptableConfig` for your tenant and SDK source. For example, from your `AppDelegate`:

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
            tenant: "acmeco",
            originSlug: "my-app",
            host: "na.edge.optable.co"
        )
        OPTABLE = OptableSDK(config: config)
        ...
        return true
    }
    ...
}
```

`tenant` is your Optable tenant name (here `acmeco`), sent as the `t` query parameter, and `originSlug` is the slug of your SDK source (here `my-app`), sent as `o`. `host` is the regional service domain enabled for your account: `na.edge.optable.co` (North America, the default), `au.edge.optable.co` (Australia / New Zealand) or `eu.edge.optable.co` (Europe). Contact your account representative if you're unsure which regions you have.

Note that while the `OPTABLE` variable is global, we initialize it with an instance of `OptableSDK` in the `application()` method which runs at app launch, and not at the time it is declared. This is done because Swift's lazy-loading otherwise delays initialization to the first use of the variable. Both approaches work, though forcing early initialization allows the SDK to configure itself early. In particular, as part of its internal configuration the SDK will attempt to read the User-Agent string exposed by WebView and, since this is an asynchronous operation, it is best done as early as possible in the application lifecycle.

You can call various SDK APIs on the instance as shown in the examples below. It's also possible to configure multiple instances of `OptableSDK` in order to connect to other (e.g., partner) DCNs and/or reference other configured application slug IDs.

Note that all SDK communication with Optable DCNs is done over TLS. The only exception to this is if you set the optional `insecure` parameter of `OptableConfig` to `true`. For example:

```swift
let config = OptableConfig(..., insecure: true)
OPTABLE = OptableSDK(config: config)
```

Note that production DCNs only listen to TLS traffic. The `insecure: true` option is meant to be used by Optable developers running the DCN locally for testing.

By default, the SDK detects the application user agent by sniffing `navigator.userAgent` from a `WKWebView`. The resulting user agent string is sent to your DCN for analytics purposes. To disable this behavior, you can provide an optional string parameter, `customUserAgent`, which allows you to set whatever user agent string you would like to send instead. For example:

```swift
let config = OptableConfig(..., customUserAgent: "custom-ua")
OPTABLE = OptableSDK(config: config)
```

The default value of `nil` for the `customUserAgent` parameter enables the `WKWebView` auto-detection behavior.

By default the SDK does not send an `Origin` HTTP header. If your DCN expects one, you can set the optional `origin` parameter to the origin you want your mobile traffic attributed to, and its value will be sent as the `Origin` header on every Optable API request (`identify`, `targeting`, `profile`, `witness`):

```swift
let config = OptableConfig(..., origin: "https://www.acmeco.com")
OPTABLE = OptableSDK(config: config)
```

### Configuration options

Besides `tenant`, `originSlug` and `host`, `OptableConfig` accepts the following optional parameters. All of them are also settable properties on the config.

| Parameter | Default | Description |
|---|---|---|
| `path` | `"v2"` | The API path, used to build request URLs such as `https://na.edge.optable.co/v2/identify`. You should not normally need to change it. |
| `insecure` | `false` | Use HTTP instead of HTTPS. Only for testing against a local DCN. |
| `apiKey` | `nil` | A Service Account API key, sent as an `Authorization: Bearer` header. Required when the API endpoint is configured as private. |
| `customUserAgent` | `nil` | A `User-Agent` to send instead of the one detected from `WKWebView`. |
| `origin` | `nil` | A value sent as the `Origin` HTTP header. |
| `skipAdvertisingIdDetection` | `false` | When `true`, the SDK never adds the device IDFA to `identify` and `targeting` requests. |
| `cacheTTL` | 24 hours | How long, in seconds, cached targeting data stays valid. |

#### Privacy and consent

The SDK forwards consent signals with every request. You can set them explicitly as properties on `OptableConfig`:

```swift
let config = OptableConfig(tenant: "acmeco", originSlug: "my-app")
config.reg = "gdpr"                 // privacy regulation override: "gdpr", "can" or "us"
config.gdpr = 1                     // whether GDPR applies: 1 or 0
config.gdprConsent = "<TCF string>" // TCF EU v2 consent string
config.gpp = "<GPP string>"         // GPP consent string
config.gppSid = "2,7"               // GPP section IDs that apply, required when gpp is set
```

If you don't set them, the SDK reads the values that an IAB-compliant consent management platform (CMP) stores in `UserDefaults`:

| Config property | `UserDefaults` fallback key | Sent as |
|---|---|---|
| `gdpr` + `gdprConsent` | `IABTCF_gdprApplies` + `IABTCF_TCString` | `gdpr`, `gdpr_consent` |
| `gpp` | `IABGPP_2_TCString` | `gpp` |
| `gppSid` | none | `gpp_sid` |
| `reg` | none | `reg` |

`gdpr` and `gdprConsent` are used together: if either one is missing from the config, the SDK ignores both and uses the `UserDefaults` values instead. `gppSid` has no `UserDefaults` fallback, so if you rely on your CMP for `gpp`, set `gppSid` yourself.

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

The SDK automatically adds the Apple ID for Advertising (IDFA) to the identifiers sent by `identify()` and `targeting()` whenever the user has authorized tracking. You don't need to pass it yourself. To turn this off, set `skipAdvertisingIdDetection` to `true` in `OptableConfig`.

> :warning: **IDFA requires user authorization**: Apple requires permission to use IDFA via the [AppTrackingTransparency](https://developer.apple.com/app-store/user-privacy-and-data-use/) framework. The SDK only reads the current authorization status and **does not** show the ATT prompt itself. Your application must request authorization, for example with `ATTrackingManager.requestTrackingAuthorization`, and must set the _Privacy - Tracking Usage Description_ (`NSUserTrackingUsageDescription`) string in its `Info.plist`. Until the user authorizes tracking, no IDFA is sent.

The frequency of invocation of `identify` is up to you, however for optimal identity resolution we recommended to call the `identify()` method on your SDK instance every time you authenticate a user, as well as periodically, such as for example once every 15 to 60 minutes while the application is being actively used and an internet connection is available.

#### Normalization before hashing

Before hashing, the SDK removes all whitespace and lowercases the value. It does **not** otherwise reformat it. In particular, phone numbers are not converted to [E.164](https://en.wikipedia.org/wiki/E.164), so `"+1 555-123-4567"`, `"+15551234567"` and `"5551234567"` produce three different hashes. Pass phone numbers in E.164 format (for example, `"+15551234567"`) so that they match the identifiers in your DCN.

#### Already-hashed identifiers

If you already have the SHA-256 hash of an email address or phone number, for example from your backend, pass it with `.hem` or `.hashedPhoneNumber` so that the SDK doesn't hash it a second time:

```swift
let ids: [OptableIdentifier] = [
    .hem("<sha256 of the normalized email address>"),
    .hashedPhoneNumber("<sha256 of the E.164 phone number>")
]
try OPTABLE!.identify(ids) { result in
    // ...
}
```

The value must be a 64-character hexadecimal SHA-256 digest, computed with the same normalization the SDK uses (whitespace removed, lowercased). The SDK lowercases the digest but does not hash it again. Values that aren't a valid SHA-256 digest are dropped and not sent, so a plain-text email address or phone number passed by mistake never leaves the device.

Do not pass a hash to `.emailAddress` or `.phoneNumber`: those cases always hash their value, so the DCN would receive a hash of the hash. Already-hashed identifiers work the same way with `targeting()`.

### Profile API

> :information_source: For more info check:
> [Optable Real-Time API Endpoints > Profile](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/profile)

To associate key value traits with the device, for eventual audience assembly, you can call the profile API as follows:

```swift
do {
    try OPTABLE!.profile(traits: ["gender": "F", "age": 38, "hasAccount": true]) { result in
        switch (result) {
        case .success(let optableTargeting):
            // profile API success, optableTargeting is the updated OptableTargeting
            // for the device, also cached for targetingFromCache()
        case .failure(let error):
            // handle profile API failure in `error`
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

The specified traits are associated with the user's device and can be matched during audience assembly.

Note that the traits are of type `[String: Any]` and should consist of key value pairs, where the keys are strings and the values are either strings, numbers, or booleans.

You can optionally pass an `id` to profile and a list of `neighbors` (related identifiers) along with the traits:

```swift
let id = OptableIdentifier.custom(nil, "user-1234").extendedIdentifier // "c:user-1234"
let neighbors = [
    OptableIdentifier.emailAddress("some.email@address.com").extendedIdentifier // "e:<sha256>"
]

try OPTABLE!.profile(traits: ["hasAccount": true], id: id, neighbors: neighbors) { result in
    // ...
}
```

> :warning: Unlike `identify()` and `targeting()`, `id` and `neighbors` are plain type-prefixed strings that are sent exactly as given: the SDK does **not** normalize or hash them. Build them from `OptableIdentifier` values with `.extendedIdentifier`, as above, so that email addresses and phone numbers are hashed before they leave the device.

### Targeting API

> :information_source: For more info check:
> [Optable Real-Time API Endpoints > Targeting](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/targeting)

To get the targeting key values associated by the configured DCN with the device in real-time, you can call the `targeting` API as follows:

```swift
do {
    try OPTABLE!.targeting() { result in
        switch result {
        case .success(let optableTargeting):
            // optableTargeting is an OptableTargeting containing:
            // - targetingData: the raw targeting response as [String: Any]
            // - gamTargetingKeywords: key-values ready for GAM custom targeting
            // - ortb2: an ORTB2 JSON string, e.g. for Prebid's global ORTB config

        case .failure(let error):
            // handle targeting API failure in `error`
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

On success, the resulting key values are typically sent as part of a subsequent ad call. Therefore we recommend that you either call `targeting()` before each ad call, or in parallel periodically, caching the resulting key values which you then provide in ad calls.

You may optionally supply identifiers to enrich the targeting request: `ids` are used to match the user, while `hids` are hint identifiers forwarded as resolver-specific `hid` parameters, used by integrations such as ID5 Mobile In-App:

```swift
let ids: [OptableIdentifier] = [
    .emailAddress("test@test.test")
]
let hids: [OptableIdentifier] = [
    .phoneNumber("+1234567890")
]

try OPTABLE!.targeting(ids, hids: hids) { result in
    // ...
}
```

> :information_source: For more details on `hid` parameters, including the supported identifier types, check:
> [Optable Real-Time API Integrations Guide > Resolver Specific Parameters > ID5 Mobile In-App](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/resolver-specific-parameters#id5-mobile-in-app)

#### Resolver-Specific Parameters

On every `targeting()` call the SDK automatically attaches the parameters required by resolver-specific integrations such as ID5 Mobile In-App:

- `bundle`: the application's bundle identifier.
- `ver`: the application's version (`CFBundleShortVersionString`).
- `ua`: the user agent of the device's default browser, detected asynchronously via `WKWebView` at SDK initialization. If a targeting call happens before detection completes, the parameter is omitted; set `customUserAgent` in `OptableConfig` to guarantee it is always present.
- `id5_signature`: the ID5 signature cached from a previous targeting response, when available.

When a targeting response contains an ID5 EID, the SDK extracts the associated signature and caches it in client storage. The cached signature persists across app restarts, is sent as `id5_signature` on subsequent targeting calls to improve ID5 resolve rates, and is removed by `targetingClearCache()`. A targeting response that contains no ID5 signature removes any previously cached one, so the SDK never sends a stale signature.

In addition, unless `skipAdvertisingIdDetection` is set in `OptableConfig`, the device IDFA is automatically added to both `ids` and `hids` when ad tracking is authorized by the user.

#### Caching Targeting Data

The `targeting` API will automatically cache resulting key value data in client storage on success. You can subsequently retrieve the cached key value data as follows:

```swift
if let cachedOptableTargeting = OPTABLE!.targetingFromCache() {
  // cachedOptableTargeting is an OptableTargeting, the same type returned by targeting()
}
```

You can also clear the locally cached targeting data:

```swift
OPTABLE!.targetingClearCache()
```

Note that both `targetingFromCache()` and `targetingClearCache()` are synchronous.

##### Cache Expiry

Cached targeting data expires 24 hours after it was fetched. Once an entry has expired, `targetingFromCache()` reports it as absent by returning `nil`, and clears it from client storage. Call `targeting()` again to refresh it.

You can change the lifetime with the optional `cacheTTL` parameter, expressed in seconds:

```swift
let config = OptableConfig(..., cacheTTL: 60 * 60) // expire cached targeting data after one hour
OPTABLE = OptableSDK(config: config)
```

The default is `OptableConfig.defaultCacheTTL`, which is 24 hours. Setting `cacheTTL` to `0` effectively disables the cache, since every entry is then already expired by the time it is read.

#### The OptableTargeting result

`targeting`, `profile` and `targetingFromCache` all return an `OptableTargeting` object with three properties:

| Property | Type | Description |
|---|---|---|
| `targetingData` | `[String: Any]` | The full targeting response from the DCN. |
| `gamTargetingKeywords` | `[String: Any]?` | Key-values ready to use as Google Ad Manager custom targeting. For each audience in the response, the key is the audience's `keyspace` and the value is its audience IDs, joined with commas. `nil` when the response has no `audience` field, and empty when it has no audiences with a `keyspace`. |
| `ortb2` | `String?` | The response's `ortb2` object as a JSON string, ready to pass to Prebid Mobile. `nil` when the response contains no `ortb2` object. |

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

### Async/await

Every API that takes a completion handler also has an `async` version, which returns the result or throws the error instead:

```swift
do {
    let response = try await OPTABLE!.identify([.emailAddress("some.email@address.com")])
    let optableTargeting = try await OPTABLE!.targeting()
    let profileTargeting = try await OPTABLE!.profile(traits: ["hasAccount": true])
    let witnessResponse = try await OPTABLE!.witness(event: "example.event.type", properties: ["example": "value"])
} catch {
    // handle API failure in `error`
}
```

`identify` and `witness` return an `HTTPURLResponse`, while `targeting` and `profile` return an `OptableTargeting`. The `async` versions take the same optional parameters as the completion handler versions, such as `hids` for `targeting` and `id` and `neighbors` for `profile`.

### Integrating GAM360

We can further extend the above `targeting` example to show an integration with a [Google Ad Manager 360](https://admanager.google.com/home/) ad server account.

It's suggested to load the GAM banner view with an ad even when the call to your DCN `targeting()` method results in failure:

```swift
import GoogleMobileAds
...

do {
    try OPTABLE!.targeting() { result in
        let optableTargeting: OptableTargeting?

        switch result {
        case .success(let targeting):
            optableTargeting = targeting

        case .failure(let error):
            // handle targeting API failure in `error`, and still load an ad without targeting:
            optableTargeting = nil
        }

        // The completion handler is not called on the main thread, so load the ad from there:
        DispatchQueue.main.async {
            // We assume bannerView is a BannerView instance that has already been
            // initialized and added to our view:
            bannerView.adUnitID = "/12345/some-ad-unit-id/in-your-gam360-account"

            // Build GAM ad request with key values and load banner:
            let adRequest = AdManagerRequest()
            adRequest.customTargeting = optableTargeting?.gamTargetingKeywords as? [String: Any]
            bannerView.load(adRequest)
        }
    }
} catch {
    // handle thrown exception in `error`
}
```

The example above uses the class names from version 12 and later of the Google Mobile Ads SDK (`BannerView`, `AdManagerRequest`). Earlier versions name them `GAMBannerView` and `GAMRequest`.

A working example is available in the demo application.

### Integrating Prebid Mobile

If you use [Prebid Mobile](https://docs.prebid.org/prebid-mobile/prebid-mobile.html), pass the `ortb2` string from the `OptableTargeting` result to Prebid as its global ORTB config, so that Optable data is included in bid requests. You can also add `gamTargetingKeywords` to the Google Ad Manager request that Prebid adds its bids to. If targeting fails, or the result has no `ortb2`, clear the global ORTB config so that stale data isn't sent.

```swift
import GoogleMobileAds
import PrebidMobile
...

// In the class that owns bannerAdUnit (a Prebid BannerAdUnit) and bannerView (a GAM AdManagerBannerView),
// both already initialized:
func loadPrebidAd(_ optableTargeting: OptableTargeting?) {
    // Pass Optable data to Prebid, or clear it when there is none:
    Targeting.shared.setGlobalORTBConfig(optableTargeting?.ortb2)

    let adRequest = AdManagerRequest()
    adRequest.customTargeting = optableTargeting?.gamTargetingKeywords as? [String: Any]

    bannerAdUnit.fetchDemand(adObject: adRequest) { [weak self] _ in
        DispatchQueue.main.async {
            self?.bannerView.load(adRequest)
        }
    }
}
```

Call `loadPrebidAd` from the main thread. The `targeting()` completion handler is not called on the main thread, so wrap the call in `DispatchQueue.main.async` there.

A working example is available in the demo application (`PrebidBannerViewController`).

### Identifying visitors arriving from Email newsletters

If you send Email newsletters that contain links to your application (e.g., universal links), then you may want to automatically _identify_ visitors that have clicked on any such links via their Email address.

- [Check our url identify guide](identify-from-url.md)
