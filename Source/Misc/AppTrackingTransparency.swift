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

    /// The `*_DebugOverride` knobs are test-only hooks. Each one is backed by a `Locked` box, which keeps
    /// the static accessors concurrency-safe under Swift 6 (plain `static var`s are rejected there).
    enum ATT {
        // MARK: advertisingIdentifier

        #if DEBUG
            private static let _advertisingIdentifier_DebugOverride = Locked<UUID?>(nil)
            static var advertisingIdentifier_DebugOverride: UUID? {
                get { _advertisingIdentifier_DebugOverride.withLock { $0 } }
                set { _advertisingIdentifier_DebugOverride.withLock { $0 = newValue } }
            }

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
            private static let _advertisingIdentifierAvailable_DebugOverride = Locked<Bool?>(nil)
            static var advertisingIdentifierAvailable_DebugOverride: Bool? {
                get { _advertisingIdentifierAvailable_DebugOverride.withLock { $0 } }
                set { _advertisingIdentifierAvailable_DebugOverride.withLock { $0 = newValue } }
            }
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
            private static let _trackingStatus_DebugOverride = Locked<ATTrackingManager.AuthorizationStatus?>(nil)
            static var trackingStatus_DebugOverride: ATTrackingManager.AuthorizationStatus? {
                get { _trackingStatus_DebugOverride.withLock { $0 } }
                set { _trackingStatus_DebugOverride.withLock { $0 = newValue } }
            }
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
