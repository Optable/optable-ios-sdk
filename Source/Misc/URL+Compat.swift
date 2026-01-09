//
//  URL+Compat.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

extension URL {
    mutating func compatAppend(queryItems: [URLQueryItem]) {
        if #available(iOS 16.0, *) {
            append(queryItems: queryItems)
        } else {
            guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return }
            components.queryItems?.append(contentsOf: queryItems)
            guard let url = components.url else { return }
            self = url
        }
    }
}
