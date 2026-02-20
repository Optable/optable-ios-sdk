//
//  OptableSDKIdentifier.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

public extension OptableIdentifier {
    init?(objc identifier: OptableSDKIdentifier) {
        let swiftType: OptableIdentifier

        switch identifier.type {
        case .emailAddress: swiftType = .emailAddress(identifier.value)
        case .phoneNumber: swiftType = .phoneNumber(identifier.value)
        case .postalCode: swiftType = .postalCode(identifier.value)
        case .iPv4Address: swiftType = .ipv4Address(identifier.value)
        case .iPv6Address: swiftType = .ipv6Address(identifier.value)
        case .appleIDFA: swiftType = .appleIDFA(identifier.value)
        case .googleGAID: swiftType = .googleGAID(identifier.value)
        case .rokuRIDA: swiftType = .rokuRIDA(identifier.value)
        case .samsungTIFA: swiftType = .samsungTIFA(identifier.value)
        case .amazonFireAFAI: swiftType = .amazonFireAFAI(identifier.value)
        case .netID: swiftType = .netID(identifier.value)
        case .ID5: swiftType = .id5(identifier.value)
        case .UTIQ: swiftType = .utiq(identifier.value)
        case .optableVID: swiftType = .optableVID(identifier.value)
        case .custom:
            swiftType = .custom(identifier.customIdx?.intValue, identifier.value)
        @unknown default:
            return nil
        }
        
        self = swiftType
    }
}
