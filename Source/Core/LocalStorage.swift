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
    private let id5SignatureKey: String

    let keyPfx: String = "OPTABLE"
    var passportKey: String
    var targetingKey: String
    var targetingStoredAtKey: String
    
    private let config: OptableConfig
    
    private let lock = NSLock()

    init(_ config: OptableConfig) {
        // The key used for storage should be unique to the host+app that this instance was initialized with:
        let base64Key: String? = [config.host, config.tenant, config.originSlug]
            .joined(separator: "/")
            .data(using: .utf8)?
            .base64EncodedString()

        self.config = config

        self.passportKey = self.keyPfx + "_PASS_" + (base64Key ?? "UNKNOWN")
        self.targetingKey = self.keyPfx + "_TGT_" + (base64Key ?? "UNKNOWN")

        self.targetingDataKey = targetingKey + "_targetingData"
        self.gamTargetingKeywordsKey = targetingKey + "_gamTargetingKeywords"
        self.ortb2Key = targetingKey + "_ortb2"
        self.id5SignatureKey = targetingKey + "_id5Signature"
        self.targetingStoredAtKey = targetingKey + "_storedAt"
    }

    func getPassport() -> String? {
        return UserDefaults.standard.string(forKey: passportKey)
    }

    func setPassport(_ passport: String) {
        UserDefaults.standard.set(passport, forKey: passportKey)
    }

    func getTargeting() -> OptableTargeting? {
        lock.synchronized {
            guard let targetingData = UserDefaults.standard.object(forKey: targetingDataKey) as? [String: Any] else {
                return nil
            }

            guard isTargetingFresh() else {
                removeTargetingEntry()
                return nil
            }

            return OptableTargeting(
                optableTargeting: targetingData,
                gamTargetingKeywords: UserDefaults.standard.object(forKey: gamTargetingKeywordsKey) as? [String: Any],
                ortb2: UserDefaults.standard.string(forKey: ortb2Key)
            )
        }
    }

    func setTargeting(_ targeting: OptableTargeting) {
        lock.synchronized {
            // Decompose object explicitly
            // Because Codable/NSSecureCoding does not support heterogeneous containers such as NSDictionary([String: Any])
            // However UserDefaults does support
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: targetingStoredAtKey)
            UserDefaults.standard.setValue(targeting.targetingData, forKey: targetingDataKey)
            UserDefaults.standard.setValue(targeting.gamTargetingKeywords, forKey: gamTargetingKeywordsKey)
            UserDefaults.standard.setValue(targeting.ortb2, forKey: ortb2Key)
        }
    }

    func clearTargeting() {
        lock.synchronized { removeTargetingEntry() }
    }
    
    func getID5Signature() -> String? {
        UserDefaults.standard.string(forKey: id5SignatureKey)
    }
    
    func setID5Signature(_ signature: String?) {
        UserDefaults.standard.set(signature, forKey: id5SignatureKey)
    }

    /// Removes every key of the targeting entry.
    private func removeTargetingEntry() {
        UserDefaults.standard.removeObject(forKey: targetingDataKey)
        UserDefaults.standard.removeObject(forKey: gamTargetingKeywordsKey)
        UserDefaults.standard.removeObject(forKey: ortb2Key)
        UserDefaults.standard.removeObject(forKey: id5SignatureKey)
        UserDefaults.standard.removeObject(forKey: targetingStoredAtKey)
    }

    /// Whether the stored targeting entry was fetched recently enough to still be served, per `config.cacheTTL`. The caller must hold `lock`.
    private func isTargetingFresh() -> Bool {
        // NOTE: A missing timestamp means the entry predates cache expiry support, so its age is unknowable - treat it as expired.
        guard let storedAt = UserDefaults.standard.object(forKey: targetingStoredAtKey) as? TimeInterval else {
            return false
        }
        
        let age = Date().timeIntervalSince1970 - storedAt
        
        return age >= 0 && age < config.cacheTTL
    }
}
