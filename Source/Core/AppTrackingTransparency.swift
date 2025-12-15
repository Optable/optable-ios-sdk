//
//  AppTrackingTransparency.swift
//  OptableSDK
//
//  Created by user on 15.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

#if canImport(AdSupport)

    import AdSupport

    #if canImport(AppTrackingTransparency)
        import AppTrackingTransparency
    #endif

    import Foundation

    enum ATT {
        static var advertisingIdentifier: UUID {
            ASIdentifierManager.shared().advertisingIdentifier
        }

        @available(iOS, introduced: 6, deprecated: 14, message: "This has been replaced by functionality in AppTrackingTransparency's ATTrackingManager class.")
        static var isAdvertisingTrackingEnabled: Bool {
            ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }

        static var adfaAvailable: Bool {
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
        
        static var attAvailable: Bool {
            if #available(iOS 14, *) {
                return true
            } else {
                return false
            }
        }

        #if canImport(AppTrackingTransparency)

            static var canAuthorize: Bool {
                if #available(iOS 14, *) {
                    return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
                } else {
                    return false
                }
            }

            @available(iOS 14, *)
            static var trackingStatus: ATTrackingManager.AuthorizationStatus {
                ATTrackingManager.trackingAuthorizationStatus
            }

            @available(iOS 14, *)
            static func requestATTAuthorization(completion: ((Bool) -> Void)? = nil) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized: completion?(true)
                    case .denied, .notDetermined, .restricted: completion?(false)
                    @unknown default: completion?(true)
                    }
                }
            }

            @available(iOS 14, *)
            @discardableResult
            static func requestATTAuthorization() async -> Bool {
                await withCheckedContinuation({ continuation in
                    requestATTAuthorization(completion: { isAuthorized in
                        continuation.resume(returning: isAuthorized)
                    })
                })
            }

        #endif
    }

#endif
