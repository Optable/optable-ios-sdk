//
//  Bundle++.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

extension Bundle {
    /// The app's release version (`CFBundleShortVersionString`), if present.
    var appVersionString: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
