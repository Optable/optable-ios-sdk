//
//  OptableConfig.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

/**
 The configuration of an `OptableSDK` instance.

 Every property is backed by its own lock, so the integrator may read and write it from any thread while the SDK
 reads it.
 */
@objc
public final class OptableConfig: NSObject, Sendable {
    // MARK: Constants
    /// The default lifetime of cached targeting data: 24 hours.
    @objc
    public static let defaultCacheTTL: TimeInterval = 24 * 60 * 60

    // MARK: Required
    /// The tenant name associated with the configuration. E.g. `acmeco.optable.co` => `acmeco`.
    @objc
    public var tenant: String {
        get { tenantStore.withLock { $0 } }
        set { tenantStore.withLock { $0 = newValue } }
    }
    private let tenantStore: Locked<String>

    /// The DCN's Source Slug. E.g. `acmeco-sdk`.
    @objc
    public var originSlug: String {
        get { originSlugStore.withLock { $0 } }
        set { originSlugStore.withLock { $0 = newValue } }
    }
    private let originSlugStore: Locked<String>

    // MARK: Optional
    /// The hostname of the Optable endpoint. Default value is "na.edge.optable.co".
    @objc
    public var host: String {
        get { hostStore.withLock { $0 } }
        set { hostStore.withLock { $0 = newValue } }
    }
    private let hostStore = Locked("na.edge.optable.co")

    /// The API path to be appended to the host. Default value is "v2".
    @objc
    public var path: String {
        get { pathStore.withLock { $0 } }
        set { pathStore.withLock { $0 = newValue } }
    }
    private let pathStore = Locked("v2")

    /// Boolean flag that determines if insecure HTTP should be used instead of HTTPS. Default is false.
    @objc
    public var insecure: Bool {
        get { insecureStore.withLock { $0 } }
        set { insecureStore.withLock { $0 = newValue } }
    }
    private let insecureStore = Locked(false)

    /// An optional API key for authentication. If the API Endpoint is enabled as private, a Service Account API key will be required.
    @objc
    public var apiKey: String? {
        get { apiKeyStore.withLock { $0 } }
        set { apiKeyStore.withLock { $0 = newValue } }
    }
    private let apiKeyStore = Locked<String?>(nil)

    /// An optional custom user agent string for network requests.
    @objc
    public var customUserAgent: String? {
        get { customUserAgentStore.withLock { $0 } }
        set { customUserAgentStore.withLock { $0 = newValue } }
    }
    private let customUserAgentStore = Locked<String?>(nil)

    /// An optional value sent as the `Origin` HTTP header on every Optable API request,
    /// identifying the origin you want your mobile traffic attributed to. E.g. `https://www.acmeco.com`.
    /// When `nil` (the default), no `Origin` header is sent. Unrelated to `originSlug`.
    @objc
    public var origin: String? {
        get { originStore.withLock { $0 } }
        set { originStore.withLock { $0 = newValue } }
    }
    private let originStore = Locked<String?>(nil)

    /// Boolean flag to skip the detection of advertising IDs. Default is false.
    @objc
    public var skipAdvertisingIdDetection: Bool {
        get { skipAdvertisingIdDetectionStore.withLock { $0 } }
        set { skipAdvertisingIdDetectionStore.withLock { $0 = newValue } }
    }
    private let skipAdvertisingIdDetectionStore = Locked(false)

    /**
     How long, in seconds, targeting data cached by the `targeting` API stays valid. Default is `defaultCacheTTL` (24 hours).

     Once a cached entry is older than this, `targetingFromCache()` reports it as absent and drops it from storage.
     A value of `0` therefore disables caching entirely.
     */
    @objc
    public var cacheTTL: TimeInterval {
        get { cacheTTLStore.withLock { $0 } }
        set { cacheTTLStore.withLock { $0 = newValue } }
    }
    private let cacheTTLStore = Locked(OptableConfig.defaultCacheTTL)

    // MARK: Privacy Regulations
    /**
     Optable privacy regulation override, which can be one of: gdpr, can, us, or null and will override all other privacy regulations when present.
     */
    @objc
    public var reg: String? {
        get { regStore.withLock { $0 } }
        set { regStore.withLock { $0 = newValue } }
    }
    private let regStore = Locked<String?>(nil)

    /**
     TCF EU v2 consent string.

     > If not set, SDK will try to fetch data from UserDefaults => `IABTCF_TCString`, as stated in [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)
     */
    @objc
    public var gdprConsent: String? {
        get { gdprConsentStore.withLock { $0 } }
        set { gdprConsentStore.withLock { $0 = newValue } }
    }
    private let gdprConsentStore = Locked<String?>(nil)

    /**
     A boolean indicating whether GDPR applies, represented as a integer (0 when it does not apply, 1 when it does). This value should be present when gdpr_consent is supplied.

     > If not set, SDK will try to fetch data from UserDefaults => `IABTCF_gdprApplies`, as stated in [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)
     */
    @objc
    public var gdpr: NSNumber? {
        get { gdprStore.withLock { $0 } }
        set { gdprStore.withLock { $0 = newValue } }
    }
    private let gdprStore = Locked<NSNumber?>(nil)

    /**
     GPP privacy string.

     > If not set, SDK will try to fetch data from UserDefaults => `IABGPP_2_TCString`, as stated in [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)
     */
    @objc
    public var gpp: String? {
        get { gppStore.withLock { $0 } }
        set { gppStore.withLock { $0 = newValue } }
    }
    private let gppStore = Locked<String?>(nil)

    /**
     A comma-separated list of up to two sections applicable in a given GPP privacy string. This value is required when gpp is present.
     */
    @objc
    public var gppSid: String? {
        get { gppSidStore.withLock { $0 } }
        set { gppSidStore.withLock { $0 = newValue } }
    }
    private let gppSidStore = Locked<String?>(nil)

    // MARK: Inits
    /**
     - Parameters:
     - tenant: The tenant name associated with the configuration. E.g. `acmeco.optable.co` => `acmeco`.
     - originSlug: The DCN's Source Slug. E.g. `acmeco-sdk`.
     */
    @objc
    public init(tenant: String, originSlug: String) {
        self.tenantStore = Locked(tenant)
        self.originSlugStore = Locked(originSlug)
        super.init()
    }

    /**
     - Parameters:
     - tenant: The tenant name associated with the configuration. E.g. `acmeco.optable.co` => `acmeco`.
     - originSlug: The DCN's Source Slug. E.g. `acmeco-sdk`.
     - host: The hostname of the Optable endpoint. Default value is "na.edge.optable.co".
     - path: The API path to be appended to the host. Default value is "v2".
     - insecure: Boolean flag that determines if insecure HTTP should be used instead of HTTPS. Default is false.
     - apiKey: An optional API key for authentication. If the API Endpoint is enabled as private, a Service Account API key will be required.
     - customUserAgent: An optional custom user agent string for network requests.
     - origin: An optional value sent as the `Origin` HTTP header on every Optable API request, identifying the origin you want your mobile traffic attributed to. E.g. `https://www.acmeco.com`. No header is sent when nil. Unrelated to `originSlug`.
     - skipAdvertisingIdDetection: Boolean flag to skip the detection of advertising IDs. Default is false.
     - cacheTTL: How long, in seconds, cached targeting data stays valid. Default is `defaultCacheTTL` (24 hours).
     */
    public init(
        tenant: String,
        originSlug: String,
        host: String = "na.edge.optable.co",
        path: String = "v2",
        insecure: Bool = false,
        apiKey: String? = nil,
        customUserAgent: String? = nil,
        origin: String? = nil,
        skipAdvertisingIdDetection: Bool = false,
        cacheTTL: TimeInterval = OptableConfig.defaultCacheTTL
    ) {
        self.tenantStore = Locked(tenant)
        self.originSlugStore = Locked(originSlug)
        super.init()
        self.host = host
        self.path = path
        self.insecure = insecure
        self.apiKey = apiKey
        self.customUserAgent = customUserAgent
        self.origin = origin
        self.skipAdvertisingIdDetection = skipAdvertisingIdDetection
        self.cacheTTL = cacheTTL
    }
}
