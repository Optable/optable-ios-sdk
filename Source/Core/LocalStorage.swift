//
//  LocalStorage.swift
//  OptableSDK
//
//  The OptableSDK keeps some state in UserDefaults (https://developer.apple.com/documentation/foundation/userdefaults), a key/value store persisted
//  across launches of the app.  The state is therefore unique to the app+device, and not globally unique to the app across devices.
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

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

    func getTargeting() -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: targetingKey)
    }

    func setTargeting(_ keyvalues: [String: Any]) {
        UserDefaults.standard.setValue(keyvalues, forKey: targetingKey)
    }

    func clearTargeting() {
        UserDefaults.standard.removeObject(forKey: targetingKey)
    }
}
