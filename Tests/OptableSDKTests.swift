//
//  OptableSDKTests.swift
//  OptableSDKTests
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

@testable import OptableSDK
import XCTest

class OptableSDKTests: XCTestCase {
    var config: OptableConfig!
    var sdk: OptableSDK!

    let defaultConfig = OptableConfig(tenant: "test-tenant", originSlug: "test-slug", insecure: false)

    override func setUpWithError() throws {
        config = defaultConfig
        sdk = OptableSDK(config: config)
    }

    override func tearDownWithError() throws {}

    func test_identify() throws {
        // TODO: impl
    }

    func test_target() throws {
        // TODO: impl
    }

    func test_witness() throws {
        // TODO: impl
    }

    func test_profile() throws {
        // TODO: impl
    }
}
