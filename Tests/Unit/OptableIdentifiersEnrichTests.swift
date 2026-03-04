//
//  OptableIdentifiersEnrichTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import XCTest

@testable import OptableSDK

private let systemIDFA: String = "9A8C574D-0B13-45B3-AC67-7CA9C8851920"
private let userIDFA: String = "7F51D71F-3D94-436D-B3FE-CEF646011359"
private let userIDFA_2: String = "543769CE-8339-4502-8D1F-4764008C5C37"

// MARK: - OptableIdentifiersEnrichTests
class OptableIdentifiersEnrichTests: XCTestCase {
    func test_enrich_user_idfa_prepend() {
        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = true
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == userIDFA, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }
    }

    func test_enrich_user_idfas_prepend() {
        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))
        identifiers.append(.appleIDFA(userIDFA_2))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = true
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == userIDFA, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }

        if case let .appleIDFA(value) = identifiers[1] {
            XCTAssert(value == userIDFA_2, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }
    }

    func test_enrich_system_idfa_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }
    }

    @available(iOS 14, *)
    func test_enrich_system_idfa_same_as_user_idfa_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(systemIDFA))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "prepended idfa is not the same as system provided")
        } else {
            XCTFail("system idfa is not prepended")
        }

        if case .appleIDFA = identifiers[1] {
            XCTFail("duplicated idfa-s")
        } else if identifiers.count(where: { if case .appleIDFA = $0 { return true } else { return false } }) > 1 {
            XCTFail("duplicated idfa-s")
        }
    }

    @available(iOS 14, *)
    func test_enrich_system_idfa_user_idfa_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "prepended idfa is not the same as system provided")
        } else {
            XCTFail("system idfa is not prepended")
        }

        if case let .appleIDFA(value) = identifiers[1] {
            XCTAssert(value == userIDFA, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }
    }

    func test_enrich_system_idfa_user_idfas_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))
        identifiers.append(.appleIDFA(userIDFA_2))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }

        if case let .appleIDFA(value) = identifiers[1] {
            XCTAssert(value == userIDFA, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }

        if case let .appleIDFA(value) = identifiers[2] {
            XCTAssert(value == userIDFA_2, "prepended idfa is not the same as user provided")
        } else {
            XCTFail("user idfa is not prepended")
        }
    }

    // MARK: Builders

    func buildSDK() -> OptableSDK {
        return OptableSDK(config: OptableConfig(
            tenant: T.api.tenant.prebidtest,
            originSlug: T.api.slug.iosSDK,
            insecure: false,
            customUserAgent: T.api.userAgent,
            skipAdvertisingIdDetection: true
        ))
    }

    func buildIdentifiers() -> [OptableIdentifier] {
        [
            .emailAddress("test@test.com"),
            .phoneNumber("1234567890"),
            .postalCode("12345"),
            .ipv4Address("127.0.0.1"),
            .ipv6Address("2001:db8::7"),
        ]
    }
}
