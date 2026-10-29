//
//  OptableSDKIdentifier.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

// MARK: - OptableSDKIdentifierType
/// Identifier types for Objective-C callers. The `@objc` names keep the `OptableSDKIdentifierType_*` spelling of the
/// former Objective-C header, so existing Objective-C code compiles unchanged.
@objc
public enum OptableSDKIdentifierType: Int, Sendable {
    @objc(OptableSDKIdentifierType_EmailAddress) case emailAddress
    @objc(OptableSDKIdentifierType_PhoneNumber) case phoneNumber
    @objc(OptableSDKIdentifierType_PostalCode) case postalCode

    @objc(OptableSDKIdentifierType_IPv4Address) case iPv4Address
    @objc(OptableSDKIdentifierType_IPv6Address) case iPv6Address

    @objc(OptableSDKIdentifierType_AppleIDFA) case appleIDFA
    @objc(OptableSDKIdentifierType_GoogleGAID) case googleGAID
    @objc(OptableSDKIdentifierType_RokuRIDA) case rokuRIDA
    @objc(OptableSDKIdentifierType_SamsungTIFA) case samsungTIFA
    @objc(OptableSDKIdentifierType_AmazonFireAFAI) case amazonFireAFAI

    @objc(OptableSDKIdentifierType_NetID) case netID
    @objc(OptableSDKIdentifierType_ID5) case ID5
    @objc(OptableSDKIdentifierType_UTIQ) case UTIQ

    @objc(OptableSDKIdentifierType_Custom) case custom

    @objc(OptableSDKIdentifierType_OptableVID) case optableVID

    /// Already-hashed values, normalized but not hashed again.
    @objc(OptableSDKIdentifierType_HEM) case HEM
    @objc(OptableSDKIdentifierType_HashedPhoneNumber) case hashedPhoneNumber
}

// MARK: - OptableSDKIdentifier
/**
 Objective-C counterpart of `OptableIdentifier`, accepted by the delegate-based `identify` and `targeting` methods.

 Written in Swift so that the Swift package can ship it: SwiftPM does not allow Objective-C and Swift sources in one target.
 */
@objc
public final class OptableSDKIdentifier: NSObject, Sendable {
    @objc public let type: OptableSDKIdentifierType
    @objc public let customIdx: NSNumber? // support of the custom ids ( c1, c2, c3 )
    @objc public let value: String

    /// Designated initializer
    @objc
    public init(type: OptableSDKIdentifierType, value: String, customIdx: NSNumber? = nil) {
        self.type = type
        self.value = value
        self.customIdx = customIdx
        super.init()
    }

    /// Convenience initializer using raw type string ("e", "c3", "id5", etc.)
    @objc
    public convenience init?(typeRawValue: String, value: String) {
        guard let (type, customIdx) = Self.parse(typeRawValue: typeRawValue) else { return nil }
        self.init(type: type, value: value, customIdx: customIdx)
    }

    /// Convenience initializer using raw type string ("e", "c3", "id5", etc.)
    @nonobjc
    public convenience init?(rawType: String, value: String) {
        self.init(typeRawValue: rawType, value: value)
    }

    /// Convenience initializer using the packed "type:value" form, e.g. "c9:custom-9-id"
    @nonobjc
    public convenience init?(string: String) {
        guard let separator = string.firstIndex(of: ":") else { return nil }

        let typeRaw = String(string[..<separator])
        let value = String(string[string.index(after: separator)...])

        guard var (type, customIdx) = Self.parse(typeRawValue: typeRaw) else { return nil }

        // The packed form carries either a plaintext value or one that is already
        // hashed, so the value itself decides which. Without this, a caller passing
        // "e:<sha256>" would have it hashed a second time.
        if Self.isSHA256Hex(value) {
            if type == .emailAddress {
                type = .HEM
                customIdx = nil
            } else if type == .phoneNumber {
                type = .hashedPhoneNumber
                customIdx = nil
            }
        }

        self.init(type: type, value: value, customIdx: customIdx)
    }
}

// MARK: - Objective-C factory methods
public extension OptableSDKIdentifier {
    // Swift callers use the initializers above; these keep the class methods of the former Objective-C header.

    /// Convenience factory method
    @available(swift, obsoleted: 1)
    @objc(identifierWithType:value:)
    static func identifier(type: OptableSDKIdentifierType, value: String) -> OptableSDKIdentifier {
        OptableSDKIdentifier(type: type, value: value)
    }

    /// Convenience factory method
    @available(swift, obsoleted: 1)
    @objc(identifierWithType:value:customIdx:)
    static func identifier(type: OptableSDKIdentifierType, value: String, customIdx: NSNumber?) -> OptableSDKIdentifier {
        OptableSDKIdentifier(type: type, value: value, customIdx: customIdx)
    }

    /// Convenience factory method
    @available(swift, obsoleted: 1)
    @objc(identifierWithRawType:value:)
    static func identifier(rawType: String, value: String) -> OptableSDKIdentifier? {
        OptableSDKIdentifier(rawType: rawType, value: value)
    }

    /// Convenience factory method
    @available(swift, obsoleted: 1)
    @objc(identifierWithString:)
    static func identifier(string: String) -> OptableSDKIdentifier? {
        OptableSDKIdentifier(string: string)
    }
}

// MARK: - Private
private extension OptableSDKIdentifier {
    static func parse(typeRawValue: String) -> (OptableSDKIdentifierType, NSNumber?)? {
        switch typeRawValue {
        case "e": return (.emailAddress, nil)
        case "p": return (.phoneNumber, nil)
        case "z": return (.postalCode, nil)
        case "i4": return (.iPv4Address, nil)
        case "i6": return (.iPv6Address, nil)
        case "a": return (.appleIDFA, nil)
        case "g": return (.googleGAID, nil)
        case "r": return (.rokuRIDA, nil)
        case "s": return (.samsungTIFA, nil)
        case "f": return (.amazonFireAFAI, nil)
        case "n": return (.netID, nil)
        case "id5": return (.ID5, nil)
        case "utiq": return (.UTIQ, nil)
        case "v": return (.optableVID, nil)
        case "c": return (.custom, nil)
        default:
            // Handle custom: c1, c2, ...
            guard typeRawValue.hasPrefix("c") else { return nil }

            let suffix = typeRawValue.dropFirst()
            guard suffix.allSatisfy({ $0.isASCII && $0.isNumber }), let index = Int(suffix) else { return nil }

            return (.custom, NSNumber(value: index))
        }
    }

    /// An Email address always contains "@", which is not a hex character, so a
    /// plaintext value can never be mistaken for a SHA256 digest.
    static func isSHA256Hex(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy(sha256HexCharacters.contains)
    }

    static let sha256HexCharacters = Set("0123456789abcdefABCDEF".utf8)
}
