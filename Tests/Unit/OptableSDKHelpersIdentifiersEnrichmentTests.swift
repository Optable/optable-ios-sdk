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

// MARK: - OptableSDKHelpersIdentifiersEnrichmentTests
class OptableSDKHelpersIdentifiersEnrichmentTests: XCTestCase {
    func test_idfa_detection_disabled_enrich_user_idfa_no_prepend() {
        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = true
        sdk.enrichIfNeeded(ids: &identifiers)

        if case .appleIDFA(_) = identifiers[0] {
            XCTFail("User provided IDFA should not be prepended. (System IDFA is unavailable)")
        }
    }

    func test_idfa_detection_disabled_enrich_user_idfas_no_prepend() {
        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))
        identifiers.append(.appleIDFA(userIDFA_2))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = true
        sdk.enrichIfNeeded(ids: &identifiers)

        if case .appleIDFA(_) = identifiers[0] {
            XCTFail("User IDFA should not be prepended. (System IDFA is unavailable)")
        }

        if case .appleIDFA(_) = identifiers[1] {
            XCTFail("User IDFA should not be prepended. (System IDFA is unavailable)")
        }
    }

    func test_idfa_detection_enabled_enrich_system_idfa_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "Prepended IDFA is not the same as system provided")
        } else {
            XCTFail("System IDFA is not prepended")
        }
    }

    @available(iOS 14, *)
    func test_idfa_detection_enabled_enrich_system_idfa_same_as_user_idfa_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(systemIDFA))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "Prepended IDFA is not the same as system provided")
        } else {
            XCTFail("System IDFA is not prepended")
        }

        if case .appleIDFA = identifiers[1] {
            XCTFail("User IDFA persists and was prepended. (duplicate)")
        }

        if case .appleIDFA = identifiers.last {
            XCTFail("User IDFA persists. (duplicate)")
        }

        if identifiers.count(where: { if case .appleIDFA = $0 { return true } else { return false } }) > 1 {
            XCTFail("User IDFA persists. (duplicate)")
        }
    }

    @available(iOS 14, *)
    func test_idfa_detection_enabled_enrich_system_idfa_user_idfa_persist() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "Prepended IDFA is not the same as system provided")
        } else {
            XCTFail("System IDFA is not prepended")
        }

        if identifiers.contains(where: {
            if case let .appleIDFA(value) = $0 { return value == userIDFA } else { return false }
        }) {
            if case let .appleIDFA(value) = identifiers.last {
                XCTAssert(value == userIDFA, "Persisted User IDFA is not the same as user provided")
            } else {
                XCTFail("Persisted User IDFA is not on the correct position. (should be last)")
            }
        } else {
            XCTFail("User IDFA not persists")
        }
    }

    func test_idfa_detection_enabled_enrich_system_idfa_user_idfas_persist() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuidString: systemIDFA)

        var identifiers = buildIdentifiers()
        identifiers.append(.appleIDFA(userIDFA))
        identifiers.append(.appleIDFA(userIDFA_2))

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if case let .appleIDFA(value) = identifiers[0] {
            XCTAssert(value == systemIDFA, "Prepended IDFA is not the same as system provided")
        } else {
            XCTFail("System IDFA is not prepended")
        }

        let filteredIdentifiers = identifiers.filter({
            if case let .appleIDFA(value) = $0 {
                return value == userIDFA || value == userIDFA_2
            } else { return false }
        })

        if filteredIdentifiers.count == 2 {
            if case let .appleIDFA(value1) = identifiers[identifiers.count - 2],
               case let .appleIDFA(value2) = identifiers[identifiers.count - 1] {
                XCTAssert(value1 == userIDFA && value2 == userIDFA_2, "Persisted IDFAs are not the same as User IDFAs or in wrong order")
            } else {
                XCTFail("Persisted IDFAs are not the same as User IDFAs or in wrong order")
            }
        } else {
            XCTFail("User IDFAs are not persisted")
        }
    }

    func test_idfa_detection_enabled_enrich_system_idfa_zero_uuid_no_prepend() {
        ATT.advertisingIdentifierAvailable_DebugOverride = true
        ATT.advertisingIdentifier_DebugOverride = UUID(uuid: uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

        var identifiers: [OptableIdentifier] = [
            .emailAddress("test@test.com"),
            .phoneNumber("1234567890"),
        ]

        let sdk = buildSDK()
        sdk.config.skipAdvertisingIdDetection = false
        sdk.enrichIfNeeded(ids: &identifiers)

        if identifiers.contains(where: { if case .appleIDFA = $0 { return true } else { return false } }) {
            XCTFail("Zero System IDFA should not be prepended or persisted")
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
