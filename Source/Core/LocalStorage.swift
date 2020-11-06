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

class LocalStorage: NSObject {
    let keyPfx: String = "OPTABLE"
    var passportKey: String
    var targetingKey: String

    init(_ config: Config) {
        // The key used for storage should be unique to the host+app that this instance was initialized with:
        let utf8str = (config.host + "/" + config.app).data(using: .utf8)!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))

        self.passportKey = self.keyPfx + "_PASS_" + utf8str
        self.targetingKey = self.keyPfx + "_TGT_" + utf8str
    }

    func getPassport() -> String? {
        return UserDefaults.standard.string(forKey: passportKey)
    }

    func setPassport(_ passport: String) -> Void {
        UserDefaults.standard.set(passport, forKey: passportKey)
    }

    func getTargeting() -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: targetingKey)
    }

    func setTargeting(_ keyvalues: [String: Any]) -> Void {
        UserDefaults.standard.setValue(keyvalues, forKey: targetingKey)
    }

    func clearTargeting() -> Void {
        UserDefaults.standard.removeObject(forKey: targetingKey)
    }
}
