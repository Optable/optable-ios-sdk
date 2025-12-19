//
//  Constants.swift
//  OptableSDK
//
//  Created by user on 19.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation

enum T {
    enum api {
        enum host {
            static let na: String = "na.edge.optable.co"
            static let au: String = "au.edge.optable.co"
            
            static let all: [String] = [na, au]
        }

        enum endpoint {
            static let identify: String = "identify"
            static let target: String = "target"
            static let witness: String = "witness"
            static let profile: String = "profile"
            
            static let all: [String] = [identify, target, witness, profile]
        }

        enum path {
            static let v1: String = "v1"
            static let v2: String = "v2"
            
            static let all: [String] = [v1, v2]
        }

        enum tenant {
            static let prebidtest: String = "prebidtest"
            static let test: String = "test-tenant"
            
            static let all: [String] = [prebidtest, test]
        }

        enum slug {
            static let iosSDK: String = "ios-sdk"
            static let jsSDK: String = "js-sdk"
            
            static let all: [String] = [iosSDK, jsSDK]
        }
        
        static let userAgent: String = "ios-integration-tests"
        
        static let apiKey: String = "test-api-key"
        static let apiKeyBearer: String = "Bearer \(apiKey)"
    }
}
