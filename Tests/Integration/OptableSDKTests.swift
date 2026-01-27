//
//  OptableSDKTests.swift
//  OptableSDKTests
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

@testable import OptableSDK
import XCTest

// MARK: - OptableSDKTests
class OptableSDKTests: XCTestCase {
    let defaultConfig = OptableConfig(tenant: T.api.tenant.prebidtest, originSlug: T.api.slug.iosSDK, insecure: false, customUserAgent: T.api.userAgent)
    lazy var sdk = OptableSDK(config: defaultConfig)

    lazy var identifyExpectation = expectation(description: "identify-delegate-expectation")
    lazy var targetExpectation = expectation(description: "target-delegate-expectation")
    lazy var witnessExpectation = expectation(description: "witness-delegate-expectation")
    lazy var profileExpectation = expectation(description: "profile-delegate-expectation")

    override func setUpWithError() throws {
        sdk.delegate = self
    }

    // MARK: Identify
    @available(iOS 13.0, *)
    func test_identify_async() async throws {
        let response = try await sdk.identify(OptableIdentifiers(emailAddress: "test@test.com"))
        XCTAssert(response.allHeaderFields.keys.contains("x-optable-visitor"))
        XCTAssert(response.statusCode == 200)
    }

    func test_identify_callback() throws {
        let expectation = expectation(description: "identify-callback-expectation")
        try sdk.identify(OptableIdentifiers(emailAddress: "test@test.com")) { result in
            switch result {
            case let .success(response):
                XCTAssert(response.allHeaderFields.keys.contains("x-optable-visitor"))
                XCTAssert(response.statusCode == 200)
            case let .failure(failure):
                XCTFail("Expected success, got error: \(failure)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func test_identify_delegate() throws {
        try sdk.identify(["e": "test@test.com"])
        wait(for: [identifyExpectation], timeout: 10)
    }

    // MARK: Target
    @available(iOS 13.0, *)
    func test_target_async() async throws {
        let response = try await sdk.targeting()
        XCTAssert(response.targetingData.allKeys.isEmpty == false)
    }

    func test_target_callback() throws {
        let expectation = expectation(description: "target-callback-expectation")
        try sdk.targeting(completion: { result in
            switch result {
            case let .success(response):
                XCTAssert(response.targetingData.allKeys.isEmpty == false)
            case let .failure(failure):
                XCTFail("Expected success, got error: \(failure)")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_target_delegate() throws {
        try sdk.targeting()
        wait(for: [targetExpectation], timeout: 10)
    }

    // MARK: Witness
    @available(iOS 13.0, *)
    func test_witness_async() async throws {
        let response: HTTPURLResponse = try await sdk.witness(event: "test", properties: ["integration-test-witness": "integration-test-witness-value"])
        XCTAssert(response.allHeaderFields.keys.contains("x-optable-visitor"))
        XCTAssert(response.statusCode == 200)
    }

    func test_witness_callbacks() throws {
        let expectation = expectation(description: "witness-callback-expectation")
        try sdk.witness(event: "test", properties: ["integration-test-witness": "integration-test-witness-value"], { result in
            switch result {
            case let .success(response):
                XCTAssert(response.allHeaderFields.keys.contains("x-optable-visitor"))
                XCTAssert(response.statusCode == 200)
            case let .failure(failure):
                XCTFail("Expected success, got error: \(failure)")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_witness_delegate() throws {
        try sdk.witness(event: "test", properties: ["integration-test-witness": "integration-test-witness-value"])
        wait(for: [witnessExpectation], timeout: 10)
    }

    // MARK: Profile
    @available(iOS 13.0, *)
    func test_profile_async() async throws {
        let response = try await sdk.profile(traits: ["integration-test-profile": "integration-test-profile-value"])
        XCTAssert(response.targetingData.allKeys.isEmpty == false)
    }

    func test_profile_callbacks() throws {
        let expectation = expectation(description: "profile-callback-expectation")
        try sdk.profile(traits: ["integration-test-profile": "integration-test-profile-value"], { result in
            switch result {
            case let .success(response):
                XCTAssert(response.targetingData.allKeys.isEmpty == false)
            case let .failure(failure):
                XCTFail("Expected success, got error: \(failure)")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_profile_delegate() throws {
        try sdk.profile(traits: ["integration-test-profile": "integration-test-profile-value"])
        wait(for: [profileExpectation], timeout: 10)
    }
}

// MARK: - OptableDelegate
extension OptableSDKTests: OptableDelegate {
    func identifyOk(_ result: HTTPURLResponse) {
        XCTAssert(result.allHeaderFields.keys.contains("x-optable-visitor"))
        XCTAssert(result.statusCode == 200)
        identifyExpectation.fulfill()
    }

    func identifyErr(_ error: NSError) {
        XCTFail("Expected success, got error: \(error)")
        identifyExpectation.fulfill()
    }

    func profileOk(_ result: OptableTargeting) {
        XCTAssert(result.targetingData.allKeys.isEmpty == false)
        profileExpectation.fulfill()
    }

    func profileErr(_ error: NSError) {
        XCTFail("Expected success, got error: \(error)")
        profileExpectation.fulfill()
    }

    func targetingOk(_ result: OptableTargeting) {
        XCTAssert(result.targetingData.allKeys.isEmpty == false)
        targetExpectation.fulfill()
    }

    func targetingErr(_ error: NSError) {
        XCTFail("Expected success, got error: \(error)")
        targetExpectation.fulfill()
    }

    func witnessOk(_ result: HTTPURLResponse) {
        XCTAssert(result.allHeaderFields.keys.contains("x-optable-visitor"))
        XCTAssert(result.statusCode == 200)
        witnessExpectation.fulfill()
    }

    func witnessErr(_ error: NSError) {
        XCTFail("Expected success, got error: \(error)")
        witnessExpectation.fulfill()
    }
}
