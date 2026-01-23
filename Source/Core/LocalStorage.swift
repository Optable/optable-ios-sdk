//
//  LocalStorage.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

/**
 The OptableSDK keeps some state in UserDefaults (https://developer.apple.com/documentation/foundation/userdefaults), a key/value store persisted across launches of the app. The state is therefore unique to the app+device, and not globally unique to the app across devices.
 */
final class LocalStorage: NSObject {
    private let targetingDataKey: String
    private let gamTargetingKeywordsKey: String
    private let ortb2Key: String

    let keyPfx: String = "OPTABLE"
    var passportKey: String
    var targetingKey: String

    init(_ config: OptableConfig) {
        // The key used for storage should be unique to the host+app that this instance was initialized with:
        let base64Key: String? = [config.host, config.tenant, config.originSlug]
            .joined(separator: "/")
            .data(using: .utf8)?
            .base64EncodedString()

        self.passportKey = self.keyPfx + "_PASS_" + (base64Key ?? "UNKNOWN")
        self.targetingKey = self.keyPfx + "_TGT_" + (base64Key ?? "UNKNOWN")

        self.targetingDataKey = targetingKey + "_targetingData"
        self.gamTargetingKeywordsKey = targetingKey + "_gamTargetingKeywords"
        self.ortb2Key = targetingKey + "_ortb2"
    }

    func getPassport() -> String? {
        return UserDefaults.standard.string(forKey: passportKey)
    }

    func setPassport(_ passport: String) {
        UserDefaults.standard.set(passport, forKey: passportKey)
    }

    func getTargeting() -> OptableTargeting? {
        guard let targetingData = UserDefaults.standard.object(forKey: targetingDataKey) as? NSDictionary else {
            return nil
        }
        let optableTargeting = OptableTargeting(
            optableTargeting: targetingData,
            gamTargetingKeywords: UserDefaults.standard.object(forKey: gamTargetingKeywordsKey) as? NSDictionary,
            ortb2: UserDefaults.standard.string(forKey: ortb2Key)
        )
        return optableTargeting
    }

    func setTargeting(_ targeting: OptableTargeting) {
        // Decompose object explicitly
        // Because Codable/NSSecureCoding does not support heterogeneous containers such as NSDictionary([String: Any])
        // However UserDefaults does support
        UserDefaults.standard.setValue(targeting.targetingData, forKey: targetingDataKey)
        UserDefaults.standard.setValue(targeting.gamTargetingKeywords, forKey: gamTargetingKeywordsKey)
        UserDefaults.standard.setValue(targeting.ortb2, forKey: ortb2Key)
    }

    func clearTargeting() {
        UserDefaults.standard.removeObject(forKey: targetingKey)
    }
}
