//
//  URL+Compat.swift
//  OptableSDK
//
//  Created by user on 19.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
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
