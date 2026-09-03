//
//  URL+Compat.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

extension URL {
    mutating func compatAppend(queryItems: [URLQueryItem]) {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return }
        components.queryItems = (components.queryItems ?? []) + queryItems
        // URLComponents leaves `+` literal in the query, but the edge decodes `+` as a space,
        // which corrupts base64 values such as the ID5 signature. Encode it explicitly.
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else { return }
        self = url
    }
}
