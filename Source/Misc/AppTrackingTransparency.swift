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

        // MARK: attAvailable

        #if DEBUG
            private static let _attAvailable_DebugOverride = Locked<Bool?>(nil)
            static var attAvailable_DebugOverride: Bool? {
                get { _attAvailable_DebugOverride.withLock { $0 } }
                set { _attAvailable_DebugOverride.withLock { $0 = newValue } }
            }
        #endif

        static var attAvailable: Bool {
            #if DEBUG
                if let override = attAvailable_DebugOverride {
                    return override
                }
            #endif

            return true
        }

        // MARK: canAuthorize

        #if DEBUG
            private static let _canAuthorize_DebugOverride = Locked<Bool?>(nil)
            static var canAuthorize_DebugOverride: Bool? {
                get { _canAuthorize_DebugOverride.withLock { $0 } }
                set { _canAuthorize_DebugOverride.withLock { $0 = newValue } }
            }
        #endif

        static var canAuthorize: Bool {
            #if DEBUG
                if let override = canAuthorize_DebugOverride {
                    return override
                }
            #endif

            return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
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

        // MARK: RequestAuthorization

        static func requestATTAuthorization(completion: (@Sendable (Bool) -> Void)? = nil) {
            #if DEBUG
                if let override = trackingStatus_DebugOverride {
                    completion?(override == .authorized)
                    return
                }
            #endif

            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    completion?(true)
                case .denied, .notDetermined, .restricted:
                    completion?(false)
                @unknown default:
                    completion?(true)
                }
            }
        }

        @discardableResult
        static func requestATTAuthorization() async -> Bool {
            await withCheckedContinuation { continuation in
                requestATTAuthorization { isAuthorized in
                    continuation.resume(returning: isAuthorized)
                }
            }
        }
    }

#endif
