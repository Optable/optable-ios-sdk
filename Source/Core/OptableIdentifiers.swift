//
//  OptableIdentifiers.swift
//  OptableSDK
//
//  Created by user on 15.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation

// MARK: - OptableIdentifiers
struct OptableIdentifiers {
    var dict: [String: String] = [:]

    init() {}

    init(_ dict: [String: String] = [:]) {
        self.dict = dict
    }

    init(_ dict: [OptableIdentifier: String]) {
        self.dict = Dictionary(uniqueKeysWithValues: dict.map({ ($0.key.rawValue, $0.value) }))
    }

    subscript(_ key: OptableIdentifier) -> String? {
        get { dict[key.rawValue] }
        set { dict[key.rawValue] = newValue }
    }

    subscript(_ key: String) -> String? {
        get { dict[key] }
        set { dict[key] = newValue }
    }

    func generateEnrichedIds() -> [String] {
        var results: [String] = []

        for (key, value) in dict {
            guard let optableIdentifier = OptableIdentifier(rawValue: key) else { continue }

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
    func encode(to encoder: any Encoder) throws {
        let enrichedIds = generateEnrichedIds()
        
        var container = encoder.unkeyedContainer()
        for eid in enrichedIds {
            try container.encode(eid)
        }
    }
}
