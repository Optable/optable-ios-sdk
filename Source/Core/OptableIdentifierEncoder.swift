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
@objc
final class OptableIdentifierEncoder: NSObject {
    ///
    ///  aaid(idfa) is a helper that returns the type-prefixed Apple ID For Advertising
    ///
    @objc
    func aaid(_ idfa: String) -> String {
        return "a:" + idfa.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    ///
    ///  cid(ppid) is a helper that returns custom type-prefixed origin-provided PPID
    ///
    @objc
    func cid(_ ppid: String) -> String {
        return "c:" + ppid.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    ///
    ///  eid(email) is a helper that returns type-prefixed SHA256(downcase(email))
    ///
    @objc
    func eid(_ email: String) -> String {
        let pfx = "e:"
        let normEmail = Data(email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).utf8)

        #if canImport(CryptoKit)
            if #available(iOS 13.0, *) {
                return pfx + SHA256.hash(data: normEmail).compactMap {
                    String(format: "%02x", $0)
                }.joined()
            } else {
                return pfx + self.cchash(normEmail)
            }
        #else
            return pfx + self.cchash(normEmail)
        #endif
    }

    @objc
    func cchash(_ input: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        input.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(input.count), &digest)
        }
        return digest.makeIterator().compactMap {
            String(format: "%02x", $0)
        }.joined()
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
    @objc
    func eidFromURL(_ urlString: String) -> String {
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

    ///
    ///  tryIdentifyFromURL(urlString) is a helper that attempts to find a valid-looking
    ///  "oeid" parameter in the specified urlString's query string parameters and, if found,
    ///  calls self.identify([oeid]).
    ///
    ///  The use for this is when handling incoming universal links which might contain an
    ///  "oeid" value with the SHA256(downcase(email)) of an incoming user, such as encoded
    ///  links in newsletter Emails sent by the application developer.
    ///
    // TODO: to remove
//    @objc
//    func tryIdentifyFromURL(_ urlString: String) throws {
//        let oeid = self.eidFromURL(urlString)
//
//        if !oeid.isEmpty {
//            try self.identify(ids: [oeid]) { _ in /* no-op */ }
//        }
//    }
}
