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
    typealias TestCaseConfiguration = (insecure: Bool, host: String, path: String, endpoint: String, tenant: String, slug: String)
    var defaultTestConfiguration: TestCaseConfiguration {
        (insecure: false, host: "na.edge.optable.co", path: "v2", endpoint: "", tenant: "test-tenant", slug: "test-slug")
    }

    /**
     Expected output:
     `https://{{Domain}}/{{API_ENDPOINT}}?t={{TENANT}}&o={{SOURCE_SLUG}}`
     
     For more info check:
     [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide)
     */
    func test_edge_api_url_generation() throws {
        
        let hosts = ["na.edge.optable.co", "au.edge.optable.co", "jp.edge.optable.co", "eu.edge.optable.co"]
        let endpoints = ["identify", "profile", "targeting", "witness", "tokenize"]
        let paths = ["v2"]
        let tenants = ["prebidtest", "test-tenant"]
        let slugs = ["ios-sdk", "js-sdk"]
        
        cartesianProduct([hosts, paths, endpoints, tenants, slugs])
            .map({ product in
                var testConfig = defaultTestConfiguration
                testConfig.host = product[0]
                testConfig.path = product[1]
                testConfig.endpoint = product[2]
                testConfig.tenant = product[3]
                testConfig.slug = product[4]
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
}
