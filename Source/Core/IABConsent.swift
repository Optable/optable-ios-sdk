//
//  IABConsent.swift
//  OptableSDK
//
//  Created by user on 19.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation

/**
 IABConsent is responsible retrieving user consent according to the IAB Transparency & Consent Framework

 For more info check: [](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md)
  */
enum IABConsent {
    enum Keys {
        static let IABTCF_TCString = "IABTCF_TCString"
        static let IABTCF_gdprApplies = "IABTCF_gdprApplies"
        static let IABGPP_2_TCString = "IABGPP_2_TCString"
    }

    static var gdprApplies: Bool? {
        if let iabValue = UserDefaults.standard.string(forKey: Keys.IABTCF_gdprApplies) {
            return NSString(string: iabValue).boolValue
        }
        return nil
    }

    static var gdprTC: String? {
        UserDefaults.standard.string(forKey: Keys.IABTCF_TCString)
    }

    static var gppTC: String? {
        UserDefaults.standard.string(forKey: Keys.IABGPP_2_TCString)
    }
}
