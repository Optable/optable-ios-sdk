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

    init(_ dict: [String: String]) {
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
}

// MARK: - Encodable
extension OptableIdentifiers: Encodable {
    func encode(to encoder: any Encoder) throws {
        guard dict.isEmpty == false else { return }
        
        var container = encoder.unkeyedContainer()
        for (key, value) in dict {
            let enrichedIdentifier = "\(key):\(value)"
            try container.encode(enrichedIdentifier)
        }
    }
}
