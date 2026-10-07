//
//  AppTrackingTransparency.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

#if canImport(AdSupport)

    import AdSupport
    import AppTrackingTransparency
    import Foundation

    enum ATT {
        // MARK: advertisingIdentifier

        #if DEBUG
            static var advertisingIdentifier_DebugOverride: UUID?
            static var advertisingIdentifier: UUID {
                advertisingIdentifier_DebugOverride ?? ASIdentifierManager.shared().advertisingIdentifier
            }
        #else
            static var advertisingIdentifier: UUID {
                ASIdentifierManager.shared().advertisingIdentifier
            }
        #endif

        // MARK: advertisingIdentifierAvailable

        #if DEBUG
            static var advertisingIdentifierAvailable_DebugOverride: Bool?
        #endif

        static var advertisingIdentifierAvailable: Bool {
            #if DEBUG
                if let override = advertisingIdentifierAvailable_DebugOverride {
                    return override
                }
            #endif

            return trackingStatus == .authorized
        }

        // MARK: trackingStatus

        #if DEBUG
            static var trackingStatus_DebugOverride: ATTrackingManager.AuthorizationStatus?
        #endif

        static var trackingStatus: ATTrackingManager.AuthorizationStatus {
            #if DEBUG
                return trackingStatus_DebugOverride ?? ATTrackingManager.trackingAuthorizationStatus
            #else
                return ATTrackingManager.trackingAuthorizationStatus
            #endif
        }
    }

#endif
