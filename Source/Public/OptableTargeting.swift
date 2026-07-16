//
//  OptableTargeting.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

@objcMembers
public class OptableTargeting: NSObject {
    public let targetingData: [String: Any]
    public let gamTargetingKeywords: [String: Any]?
    public let ortb2: String?

    public init(optableTargeting: [String: Any], gamTargetingKeywords: [String: Any]? = nil, ortb2: String? = nil) {
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

// MARK: - Helpers

extension OptableTargeting {
    
    var id5Signature: String? {
        guard let ortb2 = targetingData["ortb2"] as? [String: Any],
              let user = ortb2["user"] as? [String: Any],
              let eids = user["eids"] as? [[String: Any]] else {
            return nil
        }
        
        guard let rootRefs = targetingData["refs"] as? [String: Any] else { return nil }
        
        for eid in eids {
            guard let source = eid["source"] as? String, source.range(of: "id5", options: [.caseInsensitive]) != nil else {
                continue
            }
            
            guard let uids = eid["uids"] as? [[String: Any]] else { continue }
            
            for uid in uids {
                guard let ext = uid["ext"] as? [String: Any],
                      let optable = ext["optable"] as? [String: Any],
                      let uidRef = optable["ref"] as? String else {
                    continue
                }
                
                guard let ref = rootRefs[uidRef] as? [String: Any] else { continue }
                
                if let id5Signature = ref["signature"] as? String,
                   id5Signature.trimmingCharacters(in: .whitespaces).isEmpty == false {
                    return id5Signature
                }
            }
        }

        return nil
    }
}
