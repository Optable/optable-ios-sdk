//
//  OptableIdentifier.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

// MARK: - OptableIdentifier
/**
 Optable Identifier Types

 For more info check:
 [](https://docs.optable.co/optable-documentation/getting-started/reference/identifier-types)

 */
public enum OptableIdentifier {
    // Personal identifiers,
    case emailAddress(String) // e
    case phoneNumber(String) // p
    case postalCode(String) // z

    // IP addresses
    case ipv4Address(String) // i4
    case ipv6Address(String) // i6

    // Device IDs
    case appleIDFA(String) // a
    case googleGAID(String) // g
    case rokuRIDA(String) // r
    case samsungTIFA(String) // s
    case amazonFireAFAI(String) // f

    // Universal / identity frameworks
    case netID(String) // n
    case id5(String) // id5
    case utiq(String) // utiq

    // Custom IDs (c, c1...cN)
    case custom(Int? = nil, String) // nil = "c", 1..N = "c1"..."cN"

    // Optable VID
    case optableVID(String) // v

    public var prefix: String {
        switch self {
        case .emailAddress: return "e"
        case .phoneNumber: return "p"
        case .postalCode: return "z"
        case .ipv4Address: return "i4"
        case .ipv6Address: return "i6"
        case .appleIDFA: return "a"
        case .googleGAID: return "g"
        case .rokuRIDA: return "r"
        case .samsungTIFA: return "s"
        case .amazonFireAFAI: return "f"
        case .netID: return "n"
        case .id5: return "id5"
        case .utiq: return "utiq"
        case .custom(nil, _): return "c"
        case let .custom(n?, _): return abs(n) == 0 ? "c" : "c\(abs(n))"
        case .optableVID: return "v"
        }
    }

    public var extendedIdentifier: String {
        return OptableIdentifierEncoder.eid(self)
    }
}

// MARK: - Hashable
extension OptableIdentifier: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(extendedIdentifier)
    }
}

// MARK: - Encodable
extension OptableIdentifier: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(extendedIdentifier)
    }
}

// MARK: - Init with ExtendedIdentifier
public extension OptableIdentifier {
    init?(extendedIdentifier: String) {
        let parts = extendedIdentifier.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }

        let prefix = parts[0]
        let value = parts[1]

        switch prefix {
        case "e": self = .emailAddress(value)
        case "p": self = .phoneNumber(value)
        case "z": self = .postalCode(value)
        case "i4": self = .ipv4Address(value)
        case "i6": self = .ipv6Address(value)
        case "a": self = .appleIDFA(value)
        case "g": self = .googleGAID(value)
        case "r": self = .rokuRIDA(value)
        case "s": self = .samsungTIFA(value)
        case "f": self = .amazonFireAFAI(value)
        case "n": self = .netID(value)
        case "id5": self = .id5(value)
        case "utiq": self = .utiq(value)
        case "v": self = .optableVID(value)
        default:
            // Handle custom: c, c1, c2, ...
            if prefix.hasPrefix("c") {
                let suffix = prefix.dropFirst()

                if suffix.isEmpty {
                    self = .custom(nil, value)
                } else if let number = Int(suffix) {
                    self = .custom(number, value)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
}
