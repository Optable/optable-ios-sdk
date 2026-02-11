//
//  OptableIdentifierEncoder.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import CommonCrypto
import Foundation
#if canImport(CryptoKit)
    import CryptoKit
#endif

// MARK: - OptableIdentifierEncoder
enum OptableIdentifierEncoder {
    static func eid(_ optableIdentifier: OptableIdentifier) -> String {
        let prefix = optableIdentifier.prefix
        let eid: String = switch optableIdentifier {
        case let .emailAddress(value): email(prefix, value)
        case let .phoneNumber(value): phoneNumber(prefix, value)
        case let .postalCode(value): postalCode(prefix, value)
        case let .ipv4Address(value): ipv4(prefix, value)
        case let .ipv6Address(value): ipv6(prefix, value)
        case let .appleIDFA(value): idfa(prefix, value)
        case let .googleGAID(value): gaid(prefix, value)
        case let .rokuRIDA(value): rida(prefix, value)
        case let .samsungTIFA(value): tifa(prefix, value)
        case let .amazonFireAFAI(value): afai(prefix, value)
        case let .netID(value): netid(prefix, value)
        case let .id5(value): id5(prefix, value)
        case let .utiq(value): utiq(prefix, value)
        case let .custom(idx, value): custom(prefix, idx: idx ?? 0, value)
        case let .optableVID(value): vid(prefix, value)
        }
        return eid
    }

    /// Builds Extended Identifier from Email address
    static func email(_ prefix: String, _ email: String) -> String {
        let normalizedData = Data(email.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased().utf8)
        let identifier = sha256(data: normalizedData)
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Phone number
    static func phoneNumber(_ prefix: String, _ phoneNumber: String) -> String {
        let normalizedData = Data(phoneNumber.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased().utf8)
        let identifier = sha256(data: normalizedData)
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Postal code
    static func postalCode(_ prefix: String, _ postalCode: String) -> String {
        let identifier = postalCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from IPv4 address
    static func ipv4(_ prefix: String, _ ipv4: String) -> String {
        let identifier = ipv4.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from IPv6 address
    static func ipv6(_ prefix: String, _ ipv6: String) -> String {
        let identifier = ipv6.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Apple IDFA
    static func idfa(_ prefix: String, _ idfa: String) -> String {
        let identifier = idfa.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Google GAID
    static func gaid(_ prefix: String, _ gaid: String) -> String {
        let identifier = gaid.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Roku RIDA
    static func rida(_ prefix: String, _ rida: String) -> String {
        let identifier = rida.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Samsung TV TIFA
    static func tifa(_ prefix: String, _ tifa: String) -> String {
        let identifier = tifa.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Amazon Fire AFAI
    static func afai(_ prefix: String, _ afai: String) -> String {
        let identifier = afai.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from NetID
    static func netid(_ prefix: String, _ netid: String) -> String {
        let identifier = netid.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from ID5
    static func id5(_ prefix: String, _ id5: String) -> String {
        let identifier = id5.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Utiq
    static func utiq(_ prefix: String, _ utiq: String) -> String {
        let identifier = utiq.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined().lowercased()
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Custom Publisher Provided ID (PPID)
    static func custom(_ prefix: String, idx: Int = 0, _ ppid: String) -> String {
        let identifier = ppid.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(prefix):\(identifier)"
    }

    /// Builds Extended Identifier from Optable Visitor ID (VID)
    static func vid(_ prefix: String, _ vid: String) -> String {
        let identifier = vid.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined()
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
