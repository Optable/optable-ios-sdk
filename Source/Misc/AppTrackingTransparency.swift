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

        // MARK: attAvailable

        #if DEBUG
            static var attAvailable_DebugOverride: Bool?
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
            static var canAuthorize_DebugOverride: Bool?
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
            static var trackingStatus_DebugOverride: ATTrackingManager.AuthorizationStatus?
        #endif

        static var trackingStatus: ATTrackingManager.AuthorizationStatus {
            #if DEBUG
                return trackingStatus_DebugOverride ?? ATTrackingManager.trackingAuthorizationStatus
            #else
                return ATTrackingManager.trackingAuthorizationStatus
            #endif
        }

        // MARK: RequestAuthorization

        static func requestATTAuthorization(completion: ((Bool) -> Void)? = nil) {
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
