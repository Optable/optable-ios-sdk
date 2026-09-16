//
//  OptableConfigTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

// MARK: - OptableConfigTests
class OptableConfigTests: XCTestCase {
    func testDefaultCacheTTLIsTwentyFourHours() {
        XCTAssertEqual(OptableConfig.defaultCacheTTL, 24 * 60 * 60)
    }

    func testCacheTTLDefaultsToDefaultCacheTTL() {
        let objcInit = OptableConfig(tenant: "tenant", originSlug: "slug")
        XCTAssertEqual(objcInit.cacheTTL, OptableConfig.defaultCacheTTL)

        let swiftInit = OptableConfig(tenant: "tenant", originSlug: "slug", host: "host")
        XCTAssertEqual(swiftInit.cacheTTL, OptableConfig.defaultCacheTTL)
    }

    func testCacheTTLIsConfigurable() {
        let config = OptableConfig(tenant: "tenant", originSlug: "slug", cacheTTL: 60)
        XCTAssertEqual(config.cacheTTL, 60)

        config.cacheTTL = 120
        XCTAssertEqual(config.cacheTTL, 120)
    }
}
