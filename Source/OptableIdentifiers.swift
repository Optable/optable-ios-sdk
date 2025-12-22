//
//  OptableIdentifiers.swift
//  OptableSDK
//
//  Created by user on 15.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation

// MARK: - OptableIdentifiers
/**
 Optable Identifiers container

 For more info check:
 [](https://docs.optable.co/optable-documentation/getting-started/reference/identifier-types)

 */
public struct OptableIdentifiers {
    public var dict: [String: String] = [:]

    public init(
        emailAddress: String? = nil,
        phoneNumber: String? = nil,
        postalCode: String? = nil,
        ipv4Address: String? = nil,
        ipv6Address: String? = nil,
        appleIDFA: String? = nil,
        googleGAID: String? = nil,
        rokuRIDA: String? = nil,
        samsungTIFA: String? = nil,
        amazonFireAFAI: String? = nil,
        netID: String? = nil,
        id5: String? = nil,
        utiq: String? = nil,
        custom: [String: String]? = nil
    ) {
        self.dict[OptableIdentifierType.emailAddress.rawValue] = emailAddress
        self.dict[OptableIdentifierType.phoneNumber.rawValue] = phoneNumber
        self.dict[OptableIdentifierType.postalCode.rawValue] = postalCode
        self.dict[OptableIdentifierType.ipv4Address.rawValue] = ipv4Address
        self.dict[OptableIdentifierType.ipv6Address.rawValue] = ipv6Address
        self.dict[OptableIdentifierType.appleIDFA.rawValue] = appleIDFA
        self.dict[OptableIdentifierType.googleGAID.rawValue] = googleGAID
        self.dict[OptableIdentifierType.rokuRIDA.rawValue] = rokuRIDA
        self.dict[OptableIdentifierType.samsungTIFA.rawValue] = samsungTIFA
        self.dict[OptableIdentifierType.amazonFireAFAI.rawValue] = amazonFireAFAI
        self.dict[OptableIdentifierType.netID.rawValue] = netID
        self.dict[OptableIdentifierType.id5.rawValue] = id5
        self.dict[OptableIdentifierType.utiq.rawValue] = utiq
        self.dict.merge(custom ?? [:], uniquingKeysWith: { _, new in new })
    }

    public init(_ dict: [String: String] = [:]) {
        self.dict = dict
    }

    public subscript(_ key: String) -> String? {
        get { dict[key] }
        set { dict[key] = newValue }
    }

    public init(_ dict: [OptableIdentifierType: String]) {
        self.dict = Dictionary(uniqueKeysWithValues: dict.map({ ($0.key.rawValue, $0.value) }))
    }

    public subscript(_ key: OptableIdentifierType) -> String? {
        get { dict[key.rawValue] }
        set { dict[key.rawValue] = newValue }
    }
    
    public init(_ array: [String]) {
        for item in array {
            if let colonIndex = item.firstIndex(of: ":"), colonIndex > item.startIndex {
                let prefix = String(item[..<colonIndex])
                let value = String(item[item.index(after: colonIndex)...])
                if let idType = OptableIdentifierType(rawValue: prefix) {
                    // valid id
                    dict[idType.rawValue] = value
                }
            }
        }
    }

    public func generateEnrichedIds() -> [String] {
        var results: [String] = []

        for (key, value) in dict {
            guard
                value.isEmpty == false, // skip empty values
                let optableIdentifier = OptableIdentifierType(rawValue: key)
            else { continue }

            let eid: String = switch optableIdentifier {
            case .emailAddress: OptableIdentifierEncoder.email(value)
            case .phoneNumber: OptableIdentifierEncoder.phoneNumber(value)
            case .postalCode: OptableIdentifierEncoder.postalCode(value)
            case .ipv4Address: OptableIdentifierEncoder.ipv4(value)
            case .ipv6Address: OptableIdentifierEncoder.ipv6(value)
            case .appleIDFA: OptableIdentifierEncoder.idfa(value)
            case .googleGAID: OptableIdentifierEncoder.gaid(value)
            case .rokuRIDA: OptableIdentifierEncoder.rida(value)
            case .samsungTIFA: OptableIdentifierEncoder.tifa(value)
            case .amazonFireAFAI: OptableIdentifierEncoder.afai(value)
            case .netID: OptableIdentifierEncoder.netid(value)
            case .id5: OptableIdentifierEncoder.id5(value)
            case .utiq: OptableIdentifierEncoder.utiq(value)
            case let .custom(idx): OptableIdentifierEncoder.custom(idx: idx ?? 0, value)
            case .optableVID: OptableIdentifierEncoder.vid(value)
            }
            results.append(eid)
        }

        return results
    }
}

// MARK: - Encodable
extension OptableIdentifiers: Encodable {
    public func encode(to encoder: any Encoder) throws {
        let enrichedIds = generateEnrichedIds()

        var container = encoder.unkeyedContainer()
        for eid in enrichedIds {
            try container.encode(eid)
        }
    }
}
