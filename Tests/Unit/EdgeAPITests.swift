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
        // `id5_signature` is a resolver-specific parameter cached in storage from the latest targeting response,
        // and only sent alongside a cached targeting result:
        sdk.api.storage.setTargeting(OptableTargeting(optableTargeting: ["resolved_ids": ["v:123"]]))
        sdk.api.storage.setID5Signature("id5-sig-abc123")

        let email: OptableIdentifier = .emailAddress("12345")
        let phone: OptableIdentifier = .phoneNumber("54321")
        let urlRequest = try sdk.api.targeting(ids: [email, phone], hids: [email, phone])

        // Method
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.GET.rawValue)

        // Path
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssert(urlComponents.path.contains("targeting"))

        // Query: every identifier is emitted as an `id` param (email/phone are SHA-256 hashed)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "id" && $0.value == email.extendedIdentifier }) ?? false)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "id" && $0.value == phone.extendedIdentifier }) ?? false)

        // HIDs: email and phone are part of the HID set, so they are also emitted as `hid` params
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "hid" && $0.value == email.extendedIdentifier }) ?? false)
        XCTAssertTrue(urlComponents.queryItems?.contains(where: { $0.name == "hid" && $0.value == phone.extendedIdentifier }) ?? false)

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

    func test_targeting_request_omits_id5_signature_when_no_stored_targeting() throws {
        // A cached signature alone is not enough — it is only sent alongside a cached targeting result:
        sdk.api.storage.clearTargeting()
        sdk.api.storage.setID5Signature("id5-sig-abc123")

        let urlRequest = try sdk.api.targeting(ids: [.emailAddress("12345")], hids: [])
        let urlComponents = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)!

        XCTAssertNil(urlComponents.queryItems?.first(where: { $0.name == "id5_signature" }))
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
