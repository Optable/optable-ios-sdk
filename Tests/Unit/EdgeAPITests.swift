//
//  EdgeAPITests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

class EdgeAPITests: XCTestCase {
    lazy var config = OptableConfig(
        tenant: T.api.tenant.prebidtest,
        originSlug: T.api.slug.iosSDK,
        apiKey: T.api.apiKey,
        customUserAgent: T.api.userAgent,
    )
    lazy var sdk = OptableSDK(config: config)

    lazy var originConfig = OptableConfig(
        tenant: T.api.tenant.prebidtest,
        originSlug: T.api.slug.iosSDK,
        apiKey: T.api.apiKey,
        customUserAgent: T.api.userAgent,
        origin: T.api.origin,
    )
    lazy var originSDK = OptableSDK(config: originConfig)

    override func tearDown() {
        sdk.api.storage.clearTargeting()
        super.tearDown()
    }

    // MARK: URL-s
    /**
     Expected output:
     `https://{{Domain}}/{{API_ENDPOINT}}?t={{TENANT}}&o={{SOURCE_SLUG}}`

     For more info check:
     [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide)
     */
    func test_url_generation() throws {
        let hosts = T.api.host.all
        let endpoints = T.api.endpoint.all
        let paths = T.api.path.all
        let tenants = T.api.tenant.all
        let slugs = T.api.slug.all

        typealias TestCaseConfiguration = (insecure: Bool, host: String, path: String, endpoint: String, tenant: String, slug: String)

        cartesianProduct([hosts, paths, endpoints, tenants, slugs])
            .map({ product in
                let testConfig: TestCaseConfiguration = (
                    insecure: false,
                    host: product[0],
                    path: product[1],
                    endpoint: product[2],
                    tenant: product[3],
                    slug: product[4]
                )
                return testConfig
            })
            .forEach({ (testConfig: TestCaseConfiguration) in
                let edgeAPI = EdgeAPI(OptableConfig(tenant: testConfig.tenant, originSlug: testConfig.slug, host: testConfig.host, path: testConfig.path, insecure: testConfig.insecure))
                let generatedURL = edgeAPI.buildEdgeAPIURL(endpoint: testConfig.endpoint)
                let generatedURLComponents = URLComponents(url: generatedURL!, resolvingAgainstBaseURL: false)!

                XCTAssertEqual(generatedURLComponents.scheme, testConfig.insecure ? "http" : "https")
                XCTAssertEqual(generatedURLComponents.host, testConfig.host)
                XCTAssertEqual(generatedURLComponents.path, "/\(testConfig.path)/\(testConfig.endpoint)")
                XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "t" }))
                XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "t" })!.value, testConfig.tenant)
                XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "o" }))
                XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "o" })!.value, testConfig.slug)
            })
    }

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide#parameters)
     */
    func test_url_generation_privacy_regulations_empty() throws {
        UserDefaults.standard.set(nil, forKey: IABConsent.Keys.IABTCF_gdprApplies)
        UserDefaults.standard.set(nil, forKey: IABConsent.Keys.IABTCF_TCString)
        UserDefaults.standard.set(nil, forKey: IABConsent.Keys.IABGPP_2_TCString)

        let config = OptableConfig(tenant: T.api.tenant.prebidtest, originSlug: T.api.slug.iosSDK)
        let generatedURL = OptableSDK(config: config).api.buildEdgeAPIURL(endpoint: T.api.endpoint.identify)
        let generatedURLComponents = URLComponents(url: generatedURL!, resolvingAgainstBaseURL: false)!

        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "reg" }))
        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gdpr_consent" }))
        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gdpr" }))
        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gpp" }))
        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gpp_sid" }))
    }

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide#parameters)
     */
    func test_url_generation_privacy_regulations_global() throws {
        UserDefaults.standard.set("0", forKey: IABConsent.Keys.IABTCF_gdprApplies)
        UserDefaults.standard.set("globalGDPRConsent", forKey: IABConsent.Keys.IABTCF_TCString)
        UserDefaults.standard.set("globalGPP", forKey: IABConsent.Keys.IABGPP_2_TCString)

        let config = OptableConfig(tenant: T.api.tenant.prebidtest, originSlug: T.api.slug.iosSDK)
        let generatedURL = OptableSDK(config: config).api.buildEdgeAPIURL(endpoint: T.api.endpoint.identify)
        let generatedURLComponents = URLComponents(url: generatedURL!, resolvingAgainstBaseURL: false)!

        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "reg" }))
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gdpr_consent" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gdpr_consent" })!.value, "globalGDPRConsent")
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gdpr" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gdpr" })!.value, "0")
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gpp" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gpp" })!.value, "globalGPP")
        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gpp_sid" }))
    }

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide#parameters)
     */
    func test_url_generation_privacy_regulations_explicit() throws {
        UserDefaults.standard.set("0", forKey: IABConsent.Keys.IABTCF_gdprApplies)
        UserDefaults.standard.set("globalGDPRConsent", forKey: IABConsent.Keys.IABTCF_TCString)
        UserDefaults.standard.set(nil, forKey: IABConsent.Keys.IABGPP_2_TCString)

        let config = OptableConfig(tenant: T.api.tenant.prebidtest, originSlug: T.api.slug.iosSDK)
        config.reg = "reg"
        config.gdprConsent = "gdprConsent"
        config.gdpr = 1
        config.gpp = "gpp"
        config.gppSid = "gppSid"

        let generatedURL = OptableSDK(config: config).api.buildEdgeAPIURL(endpoint: T.api.endpoint.identify)
        let generatedURLComponents = URLComponents(url: generatedURL!, resolvingAgainstBaseURL: false)!

        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "reg" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "reg" })!.value, "reg")
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gdpr_consent" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gdpr_consent" })!.value, "gdprConsent")
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gdpr" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gdpr" })!.value, "1")
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gpp" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gpp" })!.value, "gpp")
        XCTAssertNotNil(generatedURLComponents.queryItems?.first(where: { $0.name == "gpp_sid" }))
        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "gpp_sid" })!.value, "gppSid")
    }

    // MARK: Header-s
    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide#parameters)
     */
    func test_header_generation() throws {
        let generatedHeaders = sdk.api.resolveHeaders().asDict

        XCTAssertEqual(generatedHeaders["User-Agent"], T.api.userAgent)
        XCTAssertEqual(generatedHeaders["Authorization"], T.api.apiKeyBearer)
        XCTAssertNil(generatedHeaders["Origin"])
    }

    /**
     When `origin` is configured, it is sent as the `Origin` header.
     */
    func test_header_generation_with_origin() throws {
        let generatedHeaders = originSDK.api.resolveHeaders().asDict

        XCTAssertEqual(generatedHeaders["User-Agent"], T.api.userAgent)
        XCTAssertEqual(generatedHeaders["Authorization"], T.api.apiKeyBearer)
        XCTAssertEqual(generatedHeaders["Origin"], T.api.origin)
    }

    /**
     `origin` is optional, and mutable after the config has been created.
     */
    func test_header_generation_origin_is_optional() throws {
        let config = OptableConfig(tenant: T.api.tenant.prebidtest, originSlug: T.api.slug.iosSDK)
        let edgeAPI = EdgeAPI(config)

        XCTAssertNil(config.origin)
        XCTAssertNil(edgeAPI.resolveHeaders().asDict["Origin"])

        config.origin = T.api.origin

        XCTAssertEqual(edgeAPI.resolveHeaders().asDict["Origin"], T.api.origin)
    }

    /**
     The `Origin` header is unrelated to `originSlug`, which is sent as the `o` query parameter.
     */
    func test_origin_does_not_affect_url_generation() throws {
        let generatedURL = originSDK.api.buildEdgeAPIURL(endpoint: T.api.endpoint.identify)
        let generatedURLComponents = URLComponents(url: generatedURL!, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(generatedURLComponents.queryItems!.first(where: { $0.name == "o" })!.value, T.api.slug.iosSDK)
        XCTAssertNil(generatedURLComponents.queryItems?.first(where: { $0.name == "origin" }))
    }

    /**
     Every endpoint carries the configured `Origin` header, and none of them carry one when it is unset.
     */
    func test_origin_header_on_all_endpoints() throws {
        typealias RequestFactory = (EdgeAPI) throws -> URLRequest?

        let factories: [RequestFactory] = [
            { try $0.identify(ids: [.postalCode("1234567890")]) },
            { try $0.targeting(ids: [.emailAddress("12345")]) },
            { try $0.profile(traits: ["test-key": "test-value"]) },
            { try $0.witness(event: "test-event", properties: ["test-key": "test-value"]) },
        ]

        try factories.forEach({ makeRequest in
            let withoutOrigin = try makeRequest(sdk.api)
            XCTAssertNil(withoutOrigin?.value(forHTTPHeaderField: "Origin"))

            let withOrigin = try makeRequest(originSDK.api)
            XCTAssertEqual(withOrigin?.value(forHTTPHeaderField: "Origin"), T.api.origin)
        })
    }

    // MARK: URLRequest-s
    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints)
     */
    func test_identify_request_generation() throws {
        let urlRequest = try sdk.api.identify(ids: [.postalCode("1234567890")])
        
        // Method
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.POST.rawValue)

        // Path
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssert(urlComponents.path.contains("identify"))

        // Body
        if let body = urlRequest?.httpBody {
            if let jsonObj = try JSONSerialization.jsonObject(with: body) as? [String] {
                XCTAssertEqual(jsonObj[0], "z:1234567890")
            } else {
                XCTFail("Not a valid JSON object")
            }
        } else {
            XCTFail("No body")
        }
    }

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/targeting)
     */
    func test_targeting_request_generation() throws {
        sdk.api.storage.setID5Signature("id5-sig-abc123")

        let email: OptableIdentifier = .emailAddress("12345")
        let phone: OptableIdentifier = .phoneNumber("54321")
        let utiq: OptableIdentifier = .utiq("496f5db5-681f-4392-acd5-0d4f6e2f6b88")
        let urlRequest = try sdk.api.targeting(ids: [email, phone], hids: [email, phone, utiq])

        // Method
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.GET.rawValue)

        // Path
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssert(urlComponents.path.contains("targeting"))

        // Query: every identifier is emitted as an `id` param (email/phone are SHA-256 hashed)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "id" && $0.value == email.extendedIdentifier }) ?? false)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "id" && $0.value == phone.extendedIdentifier }) ?? false)

        // HIDs: every identifier passed as a hint is emitted as a repeated `hid` param, regardless of type
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "hid" && $0.value == email.extendedIdentifier }) ?? false)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "hid" && $0.value == phone.extendedIdentifier }) ?? false)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "hid" && $0.value == utiq.extendedIdentifier }) ?? false)

        // Resolver-specific parameters
        XCTAssertEqual(urlComponents.queryItems?.first(where: { $0.name == "ua" })?.value, T.api.userAgent)
        XCTAssertEqual(urlComponents.queryItems?.first(where: { $0.name == "id5_signature" })?.value, "id5-sig-abc123")

        if let bundle = Bundle.main.bundleIdentifier {
            XCTAssertEqual(urlComponents.queryItems?.first(where: { $0.name == "bundle" })?.value, bundle)
        }

        if let ver = Bundle.main.appVersionString {
            XCTAssertEqual(urlComponents.queryItems?.first(where: { $0.name == "ver" })?.value, ver)
        }
    }

    func test_targeting_request_percent_encodes_plus_in_query_values() throws {
        // The edge decodes a literal `+` in the query as a space, which would corrupt
        // base64 values such as the ID5 signature; it must go out as %2B on the wire.
        sdk.api.storage.setID5Signature("sig+abc/123=")

        let urlRequest = try sdk.api.targeting(ids: [], hids: [])
        let rawQuery = try XCTUnwrap(urlRequest?.url?.query)

        XCTAssertFalse(rawQuery.contains("+"))
        XCTAssertTrue(rawQuery.contains("id5_signature=sig%2Babc/123"))

        // The decoded value round-trips unchanged
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(urlComponents.queryItems?.first(where: { $0.name == "id5_signature" })?.value, "sig+abc/123=")
    }

    func test_targeting_request_omits_id5_signature_when_no_cached_signature() throws {
        sdk.api.storage.setTargeting(OptableTargeting(optableTargeting: ["resolved_ids": ["v:123"]]))

        let urlRequest = try sdk.api.targeting(ids: [.emailAddress("12345")], hids: [])
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!

        XCTAssertNil(urlComponents.queryItems?.first(where: { $0.name == "id5_signature" }))
    }

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints/profile)
     */
    func test_profile_request_generation() throws {
        let urlRequest = try sdk.api.profile(traits: ["test-key": "test-value"], id: "c:id2", neighbors: ["c:id1", "c:id3"])
        
        // Method
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.POST.rawValue)

        // Path
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssert(urlComponents.path.contains("profile"))

        // Body
        if let body = urlRequest?.httpBody {
            if let jsonObj = try JSONSerialization.jsonObject(with: body) as? NSDictionary {
                XCTAssertEqual(jsonObj["id"] as! String, "c:id2")
                XCTAssertEqual(jsonObj["neighbors"] as! [String], ["c:id1", "c:id3"])
                XCTAssertEqual(jsonObj["traits"] as! NSDictionary, ["test-key": "test-value"])
            } else {
                XCTFail("Not a valid JSON object")
            }
        } else {
            XCTFail("No body")
        }
    }

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide/optable-real-time-api-endpoints)
     */
    func test_witness_request_generation() throws {
        let urlRequest = try sdk.api.witness(event: "test-event", properties: ["test-key": "test-value"])
        
        // Method
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.POST.rawValue)

        // Path
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssert(urlComponents.path.contains("witness"))
        
        // Body
        if let body = urlRequest?.httpBody {
            if let jsonObj = try JSONSerialization.jsonObject(with: body) as? NSDictionary {
                XCTAssertEqual(jsonObj["event"] as! String, "test-event")
                XCTAssertEqual(jsonObj["properties"] as! NSDictionary, ["test-key": "test-value"])
            } else {
                XCTFail("Not a valid JSON object")
            }
        } else {
            XCTFail("No body")
        }
    }
}
