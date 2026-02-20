//
//  OptableError.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

enum OptableError {
    static func identify(_ message: String, code: Int = -1) -> NSError {
        NSError(domain: "OptableSDK.identify", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    static func profile(_ message: String, code: Int = -1) -> NSError {
        NSError(domain: "OptableSDK.profile", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    static func targeting(_ message: String, code: Int = -1) -> NSError {
        NSError(domain: "OptableSDK.targeting", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    static func witness(_ message: String, code: Int = -1) -> NSError {
        NSError(domain: "OptableSDK.witness", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
