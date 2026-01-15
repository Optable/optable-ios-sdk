//
//  OptableTargeting.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

@objcMembers
public class OptableTargeting: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    public let targetingData: NSDictionary
    public let gamTargetingKeywords: NSDictionary?
    public let ortb2: String?

    public func encode(with coder: NSCoder) {
        coder.encode(targetingData, forKey: "targetingData")
        coder.encode(gamTargetingKeywords, forKey: "gamTargetingKeywords")
        coder.encode(ortb2, forKey: "ortb2")
    }

    public required init?(coder: NSCoder) {
        targetingData = coder.decodeObject(of: NSDictionary.self, forKey: "targetingData") ?? [:]
        gamTargetingKeywords = coder.decodeObject(of: NSDictionary.self, forKey: "gamTargetingKeywords")
        ortb2 = coder.decodeObject(of: NSString.self, forKey: "ortb2") as String?
    }

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
