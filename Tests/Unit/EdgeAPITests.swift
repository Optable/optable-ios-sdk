//
//  EdgeAPITests.swift
//  OptableSDK
//
//  Created by user on 17.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

class EdgeAPITests: XCTestCase {
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

    /**
     For more info check: [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide#parameters)
     */
    func test_header_generation() throws {
        let config = OptableConfig(
            tenant: T.api.tenant.prebidtest,
            originSlug: T.api.slug.iosSDK,
            apiKey: T.api.apiKey,
            customUserAgent: T.api.userAgent,
        )
        let sdk = OptableSDK(config: config)
        let generatedHeaders = sdk.api.resolveHeaders().asDict

        XCTAssertEqual(generatedHeaders["User-Agent"], T.api.userAgent)
        XCTAssertEqual(generatedHeaders["Authorization"], T.api.apiKeyBearer)
    }
}
