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
    /// The tenant name associated with the configuration. E.g. `acmeco.optable.co` => `acmeco`.
    public var tenant: String

    /// The DCN's Source Slug. E.g. `acmeco-sdk`.
    public var originSlug: String

    /// The hostname of the Optable endpoint. Default value is "na.edge.optable.co".
    public var host: String

    /// The API path to be appended to the host. Default value is "v2".
    public var path: String

    /// Boolean flag that determines if insecure HTTP should be used instead of HTTPS. Default is false.
    public var insecure: Bool

    /// An optional API key for authentication. If the API Endpoint is enabled as private, a Service Account API key will be required.
    public var apiKey: String?

    /// An optional custom user agent string for network requests.
    public var customUserAgent: String?

    /// Boolean flag to skip the detection of advertising IDs. Default is false.
    public var skipAdvertisingIdDetection: Bool

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

    func edgeURL(_ endpoint: String) -> URL? {
        var components = URLComponents()
        components.scheme = insecure ? "http" : "https"
        components.host = host
        components.path = "/\(path)/\(endpoint)"
        components.queryItems = [
            .init(name: "t", value: tenant.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            .init(name: "o", value: originSlug.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            .init(name: "osdk", value: OptableSDK.version.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
        ]
        return components.url
    }
}
