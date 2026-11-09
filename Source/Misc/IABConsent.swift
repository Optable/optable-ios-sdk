//
//  IABConsent.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
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
        static let IABGPP_HDR_GppString = "IABGPP_HDR_GppString"
        static let IABGPP_GppSID = "IABGPP_GppSID"
        /// Not an IAB key, read before `IABGPP_HDR_GppString` was. Kept as a fallback for apps that write it.
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
        nonBlankString(forKey: Keys.IABGPP_HDR_GppString)
            ?? nonBlankString(forKey: Keys.IABGPP_2_TCString)
    }

    /// The CMP stores section IDs separated by underscores ("2_7"); the Edge API takes them comma-separated ("2,7").
    /// Only read when `IABGPP_HDR_GppString` is set: the section IDs describe the CMP's own string and must never be sent with `IABGPP_2_TCString`.
    static var gppSid: String? {
        guard nonBlankString(forKey: Keys.IABGPP_HDR_GppString) != nil else { return nil }
        return nonBlankString(forKey: Keys.IABGPP_GppSID)?
            .replacingOccurrences(of: "_", with: ",")
    }

    /// A blank value (empty or whitespace only) counts as unset.
    private static func nonBlankString(forKey key: String) -> String? {
        guard let value = UserDefaults.standard.string(forKey: key),
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return value
    }
}
