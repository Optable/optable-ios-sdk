//
//  OptableIdentifierEncoder.swift
//  OptableSDK
//
//  Created by user on 16.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import CommonCrypto
import Foundation
#if canImport(CryptoKit)
    import CryptoKit
#endif

// MARK: - OptableIdentifierEncoder
enum OptableIdentifierEncoder {
    /// Builds Enriched Identifier from Email address
    static func email(_ email: String) -> String {
        let prefix = OptableIdentifier.emailAddress.rawValue
        let normalizedData = Data(email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        let identifier = sha256(data: normalizedData)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Phone number
    static func phoneNumber(_ phoneNumber: String) -> String {
        let prefix = OptableIdentifier.phoneNumber.rawValue
        let normalizedData = Data(phoneNumber.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        let identifier = sha256(data: normalizedData)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Postal code
    static func postalCode(_ postalCode: String) -> String {
        let prefix = OptableIdentifier.postalCode.rawValue
        let identifier = postalCode.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from IPv4 address
    static func ipv4(_ ipv4: String) -> String {
        let prefix = OptableIdentifier.ipv4Address.rawValue
        let identifier = ipv4.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from IPv6 address
    static func ipv6(_ ipv6: String) -> String {
        let prefix = OptableIdentifier.ipv6Address.rawValue
        let identifier = ipv6.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Apple IDFA
    static func idfa(_ idfa: String) -> String {
        let prefix = OptableIdentifier.appleIDFA.rawValue
        let identifier = idfa.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Google GAID
    static func gaid(_ gaid: String) -> String {
        let prefix = OptableIdentifier.googleGAID.rawValue
        let identifier = gaid.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Roku RIDA
    static func rida(_ rida: String) -> String {
        let prefix = OptableIdentifier.rokuRIDA.rawValue
        let identifier = rida.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Samsung TV TIFA
    static func tifa(_ tifa: String) -> String {
        let prefix = OptableIdentifier.samsungTIFA.rawValue
        let identifier = tifa.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Amazon Fire AFAI
    static func afai(_ afai: String) -> String {
        let prefix = OptableIdentifier.amazonFireAFAI.rawValue
        let identifier = afai.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from NetID
    static func netid(_ netid: String) -> String {
        let prefix = OptableIdentifier.netID.rawValue
        let identifier = netid.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from ID5
    static func id5(_ id5: String) -> String {
        let prefix = OptableIdentifier.id5.rawValue
        let identifier = id5.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Utiq
    static func utiq(_ utiq: String) -> String {
        let prefix = OptableIdentifier.utiq.rawValue
        let identifier = utiq.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Enriched Identifier from Custom Publisher Provided ID (PPID)
    static func custom(_ idx: Int = 0, _ ppid: String) -> String {
        let prefix = OptableIdentifier.custom(idx).rawValue
        let identifier = ppid.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }
    
    /// Builds Enriched Identifier from Optable Visitor ID (VID)
    static func vid(_ vid: String) -> String {
        let prefix = OptableIdentifier.optableVID.rawValue
        let identifier = vid.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    ///
    ///  eidFromURL(urlString) is a helper that returns a type-prefixed ID based on
    ///  the query string oeid=sha256value parameter in the specified urlString, if
    ///  one is found. Otherwise, it returns an empty string.
    ///
    ///  The use for this is when handling incoming universal links which might
    ///  contain an "oeid" value with the SHA256(downcase(email)) of a user, such as
    ///  encoded links in newsletter Emails sent by the application developer. Such
    ///  hashed Email values can be used in calls to identify()
    ///
    static func eidFromURL(_ urlString: String) -> String {
        guard let url = URL(string: urlString) else { return "" }
        guard let urlc = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return "" }
        guard let urlqis = urlc.queryItems else { return "" }

        /// Look for an oeid parameter in the urlString:
        var oeid = ""
        for qi: URLQueryItem in urlqis {
            guard let val = qi.value else {
                continue
            }
            if qi.name.lowercased() == "oeid" {
                oeid = val
                break
            }
        }

        /// Check that oeid looks like a valid SHA256:
        let range = NSRange(location: 0, length: oeid.utf16.count)
        guard let regex = try? NSRegularExpression(pattern: "[a-f0-9]{64}", options: .caseInsensitive) else { return "" }
        if (oeid.count != 64) || (regex.firstMatch(in: oeid, options: [], range: range) == nil) {
            return ""
        }

        return "e:" + oeid.lowercased()
    }

    // MARK: - Private
    private static func sha256(data: Data) -> String {
        #if canImport(CryptoKit)
            if #available(iOS 13.0, *) {
                return SHA256
                    .hash(data: data)
                    .compactMap({ String(format: "%02x", $0) })
                    .joined()
            }
        #endif

        return cchash(data)
    }

    private static func cchash(_ input: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        input.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(input.count), &digest)
        }
        return digest.makeIterator().compactMap {
            String(format: "%02x", $0)
        }.joined()
    }
}
