//
//  AppTrackingTransparency.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

#if canImport(AdSupport)

    import AdSupport

    #if canImport(AppTrackingTransparency)
        import AppTrackingTransparency
    #endif

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

        // MARK: isAdvertisingTrackingEnabled

        #if DEBUG
            @available(iOS, introduced: 6, deprecated: 14,
                       message: "Replaced by ATTrackingManager in AppTrackingTransparency.")
            static var isAdvertisingTrackingEnabled_DebugOverride: Bool?
            static var isAdvertisingTrackingEnabled: Bool {
                isAdvertisingTrackingEnabled_DebugOverride ?? ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            }
        #else
            static var isAdvertisingTrackingEnabled: Bool {
                ASIdentifierManager.shared().isAdvertisingTrackingEnabled
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

            #if canImport(AppTrackingTransparency)
                if #available(iOS 14, *) {
                    return trackingStatus == .authorized
                } else {
                    return isAdvertisingTrackingEnabled
                }
            #else
                return isAdvertisingTrackingEnabled
            #endif
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

            if #available(iOS 14, *) {
                return true
            } else {
                return false
            }
        }

        #if canImport(AppTrackingTransparency)

            // MARK: canAuthorize

            #if DEBUG
                @available(iOS 14, *)
                static var canAuthorize_DebugOverride: Bool?
            #endif

            static var canAuthorize: Bool {
                if #available(iOS 14, *) {
                    #if DEBUG
                        if let override = canAuthorize_DebugOverride {
                            return override
                        }
                    #endif

                    return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
                } else {
                    return false
                }
            }

            // MARK: trackingStatus

            #if DEBUG
                @available(iOS 14, *)
                static var trackingStatus_DebugOverride: ATTrackingManager.AuthorizationStatus?
            #endif

            @available(iOS 14, *)
            static var trackingStatus: ATTrackingManager.AuthorizationStatus {
                #if DEBUG
                    return trackingStatus_DebugOverride ?? ATTrackingManager.trackingAuthorizationStatus
                #else
                    return ATTrackingManager.trackingAuthorizationStatus
                #endif
            }

            // MARK: RequestAuthorization

            @available(iOS 14, *)
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

            @available(iOS 14, *)
            @discardableResult
            static func requestATTAuthorization() async -> Bool {
                await withCheckedContinuation { continuation in
                    requestATTAuthorization { isAuthorized in
                        continuation.resume(returning: isAuthorized)
                    }
                }
            }

        #endif
    }

#endif
