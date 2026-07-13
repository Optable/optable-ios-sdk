//
//  OptableSDK+ObjC.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

// MARK: Objective-C support

public extension OptableSDK {
    
    /**
     This is the Objective-C compatible version of the `identify(ids, completion)` API.

     Instead of completion callbacks, delegate methods are called.
     */
    @objc
    func identify(_ ids: [OptableSDKIdentifier]) throws {
        let bridgedIds = ids.compactMap({ OptableIdentifier(objc: $0) })
        try self._identify(bridgedIds) { result in
            switch result {
            case let .success(response):
                self.delegate?.identifyOk(response)
            case let .failure(error as NSError):
                self.delegate?.identifyErr(error)
            }
        }
    }
    
    /**
     This is the Objective-C compatible version of the `targeting(ids, completion)` API.

     Instead of completion callbacks, delegate methods are called.
     */
    @objc
    func targeting(_ ids: [OptableSDKIdentifier]) throws {
        try targeting(ids, hids: [])
    }

    /**
     This is the Objective-C compatible version of the `targeting(ids, hids, completion)` API.

     Instead of completion callbacks, delegate methods are called.
     */
    @objc(targetingWithIds:hids:error:)
    func targeting(_ ids: [OptableSDKIdentifier], hids: [OptableSDKIdentifier]) throws {
        let bridgedIds = ids.compactMap({ OptableIdentifier(objc: $0) })
        let bridgedHIds = hids.compactMap({ OptableIdentifier(objc: $0) })

        try self._targeting(ids: bridgedIds, hids: bridgedHIds, completion: { result in
            switch result {
            case let .success(optableTargeting):
                self.delegate?.targetingOk(optableTargeting)
            case let .failure(error as NSError):
                self.delegate?.targetingErr(error)
            }
        })
    }
}
