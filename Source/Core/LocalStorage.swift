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
    let keyPfx: String = "OPTABLE_"
    var passportKey: String

    init(_ config: Config) {
        // The key used for storing the passport should be unique to the host+app that this instance was initialized with:
        let utf8str = (config.host + "/" + config.app).data(using: .utf8)
        self.passportKey = self.keyPfx + utf8str!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    func getPassport() -> String? {
        return UserDefaults.standard.string(forKey: passportKey)
    }

    func setPassport(_ passport: String) -> Void {
        UserDefaults.standard.set(passport, forKey: passportKey)
    }    
}
