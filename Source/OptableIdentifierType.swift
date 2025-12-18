//
//  OptableIdentifierType.swift
//  OptableSDK
//
//  Created by user on 16.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation

/**
 Optable Identifier Types

 For more info check:
 [](https://docs.optable.co/optable-documentation/getting-started/reference/identifier-types)

 */
public enum OptableIdentifierType: RawRepresentable, Hashable {
    // Personal identifiers
    case emailAddress // e
    case phoneNumber // p
    case postalCode // z

    // IP addresses
    case ipv4Address // i4
    case ipv6Address // i6

    // Device IDs
    case appleIDFA // a
    case googleGAID // g
    case rokuRIDA // r
    case samsungTIFA // s
    case amazonFireAFAI // f

    // Universal / identity frameworks
    case netID // n
    case id5 // id5
    case utiq // utiq

    // Custom IDs (c, c1...cN)
    case custom(Int?) // nil = "c", 1..N = "c1"..."cN"

    // Optable VID
    case optableVID // v

    public init?(rawValue: String) {
        switch rawValue {
        case "e": self = .emailAddress
        case "p": self = .phoneNumber
        case "z": self = .postalCode
        case "i4": self = .ipv4Address
        case "i6": self = .ipv6Address
        case "a": self = .appleIDFA
        case "g": self = .googleGAID
        case "r": self = .rokuRIDA
        case "s": self = .samsungTIFA
        case "f": self = .amazonFireAFAI
        case "n": self = .netID
        case "id5": self = .id5
        case "utiq": self = .utiq
        case "c": self = .custom(nil)
        case "v": self = .optableVID
        default:
            if rawValue.starts(with: "c"),
               let number = Int(rawValue.dropFirst()) {
                self = .custom(number)
            } else {
                return nil
            }
        }
    }

    public var rawValue: String {
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
        case .custom(nil): return "c"
        case let .custom(n?): return abs(n) == 0 ? "c" : "c\(abs(n))"
        case .optableVID: return "v"
        }
    }
}
