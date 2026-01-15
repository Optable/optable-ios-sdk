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
    }

    func getPassport() -> String? {
        return UserDefaults.standard.string(forKey: passportKey)
    }

    func setPassport(_ passport: String) {
        UserDefaults.standard.set(passport, forKey: passportKey)
    }

    func getTargeting() -> OptableTargeting? {
        if let targetingData = UserDefaults.standard.data(forKey: targetingKey),
           let targeting = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: OptableTargeting.self,
               from: targetingData
           ) {
            return targeting
        }

        return nil
    }

    func setTargeting(_ targeting: OptableTargeting) {
        let targetingData = try? NSKeyedArchiver.archivedData(
            withRootObject: targeting,
            requiringSecureCoding: true
        )
        UserDefaults.standard.setValue(targetingData, forKey: targetingKey)
    }

    func clearTargeting() {
        UserDefaults.standard.removeObject(forKey: targetingKey)
    }
}
