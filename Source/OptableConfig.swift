//
//  OptableConfig.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

@objc
public class OptableConfig: NSObject {
    // MARK: Required
    /// The tenant name associated with the configuration. E.g. `acmeco.optable.co` => `acmeco`.
    @objc
    public var tenant: String

    /// The DCN's Source Slug. E.g. `acmeco-sdk`.
    @objc
    public var originSlug: String

    // MARK: Optional
    /// The hostname of the Optable endpoint. Default value is "na.edge.optable.co".
    @objc
    public var host: String = "na.edge.optable.co"

    /// The API path to be appended to the host. Default value is "v2".
    @objc
    public var path: String = "v2"

    /// Boolean flag that determines if insecure HTTP should be used instead of HTTPS. Default is false.
    @objc
    public var insecure: Bool = false

    /// An optional API key for authentication. If the API Endpoint is enabled as private, a Service Account API key will be required.
    @objc
    public var apiKey: String?

    /// An optional custom user agent string for network requests.
    @objc
    public var customUserAgent: String?

    /// Boolean flag to skip the detection of advertising IDs. Default is false.
    @objc
    public var skipAdvertisingIdDetection: Bool = false

    // MARK: Privacy Regulations
    /**
     Optable privacy regulation override, which can be one of: gdpr, can, us, or null and will override all other privacy regulations when present.
     */
    @objc
    public var reg: String?

    /**
     TCF EU v2 consent string.

     > If not set, SDK will try to fetch data from UserDefaults => `IABTCF_TCString`, as stated in [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)
     */
    @objc
    public var gdprConsent: String?

    /**
     A boolean indicating whether GDPR applies, represented as a integer (0 when it does not apply, 1 when it does). This value should be present when gdpr_consent is supplied.

     > If not set, SDK will try to fetch data from UserDefaults => `IABTCF_gdprApplies`, as stated in [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)
     */
    @objc
    public var gdpr: NSNumber? = false

    /**
     GPP privacy string.

     > If not set, SDK will try to fetch data from UserDefaults => `IABGPP_2_TCString`, as stated in [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)
     */
    @objc
    public var gpp: String?

    /**
     A comma-separated list of up to two sections applicable in a given GPP privacy string. This value is required when gpp is present.
     */
    @objc
    public var gppSid: String?

    // MARK: Inits
    /**
     - Parameters:
     - tenant: The tenant name associated with the configuration. E.g. `acmeco.optable.co` => `acmeco`.
     - originSlug: The DCN's Source Slug. E.g. `acmeco-sdk`.
     */
    @objc
    public init(tenant: String, originSlug: String) {
        self.tenant = tenant
        self.originSlug = originSlug
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
     - skipAdvertisingIdDetection: Boolean flag to skip the detection of advertising IDs. Default is false.
     */
    public init(
        tenant: String,
        originSlug: String,
        host: String = "na.edge.optable.co",
        path: String = "v2",
        insecure: Bool = false,
        apiKey: String? = nil,
        customUserAgent: String? = nil,
        skipAdvertisingIdDetection: Bool = false
    ) {
        self.tenant = tenant
        self.originSlug = originSlug
        self.host = host
        self.path = path
        self.insecure = insecure
        self.apiKey = apiKey
        self.customUserAgent = customUserAgent
        self.skipAdvertisingIdDetection = skipAdvertisingIdDetection
    }
}
