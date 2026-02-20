//
//  OptableTargeting.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

@objcMembers
public class OptableTargeting: NSObject {
    public let targetingData: NSDictionary
    public let gamTargetingKeywords: NSDictionary?
    public let ortb2: String?

    public init(optableTargeting: NSDictionary, gamTargetingKeywords: NSDictionary? = nil, ortb2: String? = nil) {
        self.targetingData = optableTargeting
        self.gamTargetingKeywords = gamTargetingKeywords
        self.ortb2 = ortb2
    }

    override public var debugDescription: String {
        var desc = "<OptableTargeting:\n"
        desc += "  targetingData: \(targetingData)\n"
        if let keywords = gamTargetingKeywords {
            desc += "  gamTargetingKeywords: \(keywords)\n"
        } else {
            desc += "  gamTargetingKeywords: nil\n"
        }
        desc += "  ortb2: \(ortb2 ?? "nil")\n"
        desc += ">"
        return desc
    }
}
