//
//  OptableSDK.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

// MARK: - OptableDelegate
/**
 OptableDelegate enables Objective-C and Swift apps to receive results via delegate callbacks.

 - Ok callbacks:
   - identifyOk and witnessOk receive an HTTPURLResponse on success.
   - targetingOk and profileOk receive an OptableTargeting result on success.
 - Err callbacks:
   - All Err methods receive an NSError describing the failure.

 Note for Objective-C callers: delegate-style APIs are exposed as throwing @objc methods.
 If a synchronous error occurs while preparing a request, the method sets the passed NSError**
 and does not invoke the delegate callbacks.
 */
@objc
public protocol OptableDelegate {
    func identifyOk(_ result: HTTPURLResponse)
    func identifyErr(_ error: NSError)
    func profileOk(_ result: OptableTargeting)
    func profileErr(_ error: NSError)
    func targetingOk(_ result: OptableTargeting)
    func targetingErr(_ error: NSError)
    func witnessOk(_ result: HTTPURLResponse)
    func witnessErr(_ error: NSError)
}

// MARK: - OptableSDK
/**
 OptableSDK exposes an API that is used by an iOS app developer integrating with an Optable Sandbox.

 An instance of OptableSDK refers to an Optable Sandbox specified by values in OptableConfig provided to the initializer.

 It is possible to create multiple instances of OptableSDK, should the developer want to integrate with multiple Sandboxes.

 The OptableSDK keeps some state in [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults), a key/value store persisted across launches of the app.  The state is therefore unique to the app+device, and not globally unique to the app across devices.
 */
@objc
public class OptableSDK: NSObject {
    @objc
    public var delegate: OptableDelegate?

    let config: OptableConfig
    let api: EdgeAPI

    /// Initializes the SDK with the provided OptableConfig.
    @objc
    public init(config: OptableConfig) {
        self.config = config
        self.api = EdgeAPI(config)
    }

    /// OptableSDK version
    static var version: String {
        let sdkBundle = Bundle(for: OptableSDK.self)

        guard
            let marketingVersion = sdkBundle.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildNumber = sdkBundle.infoDictionary?["CFBundleVersion"] as? String
        else { return "ios-unknown" }

        return ["ios", marketingVersion, buildNumber].joined(separator: "-")
    }
}

// MARK: - Identify
public extension OptableSDK {
    /**
     identify(ids, completion) calls the Optable Sandbox Identify API with the provided identifiers.

     On completion, the handler receives:
     - .success(HTTPURLResponse) on success
     - .failure(Error) on failure

     Example:
     ```swift
     // Swift
     try optableSDK.identify(
         [.emailAddress("example@example.com"), .phoneNumber("1234567890")]
     ) { result in
         // handle result
     }
     ```
     */
    func identify(_ ids: [OptableIdentifier], completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
        try _identify(ids, completion: completion)
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `identify(ids, completion)` API.

     Instead of completion callbacks, results are returned via async/await.
     */
    @available(iOS 13.0, *)
    func identify(_ ids: [OptableIdentifier]) async throws -> HTTPURLResponse {
        return try await withCheckedThrowingContinuation({ [unowned self] continuation in
            do {
                try self._identify(ids, completion: { continuation.resume(with: $0) })
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }
}

// MARK: - Targeting
public extension OptableSDK {
    /**
     targeting(ids?, completion) calls the Optable Sandbox Targeting API and returns key-value targeting data
     for the current user/device/app. You may optionally supply identifiers to enrich the request.

     On completion, the handler receives:
     - .success(OptableTargeting) on success
     - .failure(Error) on failure

     On success, the result is cached in client storage. You can read it using targetingFromCache()
     and clear it using targetingClearCache().
     */
    func targeting(_ ids: [OptableIdentifier]? = nil, completion: @escaping (Result<OptableTargeting, Error>) -> Void) throws {
        try _targeting(ids: ids, completion: completion)
    }

    /// targetingFromCache() returns the previously cached targeting data, if any.
    @objc
    func targetingFromCache() -> OptableTargeting? {
        return self.api.storage.getTargeting()
    }

    /// targetingClearCache() clears any previously cached targeting data.
    @objc
    func targetingClearCache() {
        self.api.storage.clearTargeting()
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `targeting(completion)` API.

     Instead of completion callbacks, results are returned via async/await.
     */
    @available(iOS 13.0, *)
    func targeting(_ ids: [OptableIdentifier]? = nil) async throws -> OptableTargeting {
        return try await withCheckedThrowingContinuation({ [unowned self] continuation in
            do {
                try self._targeting(ids: ids, completion: { continuation.resume(with: $0) })
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }
}

// MARK: - Witness
public extension OptableSDK {
    /**
     witness(event, properties, completion) calls the Optable Sandbox Witness API to log an event
     (for example, "app.screenView" or "ui.buttonPressed") with the provided properties.
     These events can later be used for audience assembly.

     On completion, the handler receives:
     - .success(HTTPURLResponse) on success
     - .failure(Error) on failure
     */
    func witness(event: String, properties: [String: Any], _ completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
        try _witness(event: event, properties: properties, completion: completion)
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `witness(event, properties, completion)` API.

     Instead of completion callbacks, results are returned via async/await.
     */
    @available(iOS 13.0, *)
    func witness(event: String, properties: [String: Any]) async throws -> HTTPURLResponse {
        return try await withCheckedThrowingContinuation({ [unowned self] continuation in
            do {
                try self._witness(event: event, properties: properties, completion: { continuation.resume(with: $0) })
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }

    // MARK: Objective-C support
    /**
     This is the Objective-C compatible version of the `witness(event, properties, completion)` API.

     Instead of completion callbacks, delegate methods are called.
     */
    @objc
    func witness(event: String, properties: [String: Any]) throws {
        try self.witness(event: event, properties: properties) { result in
            switch result {
            case let .success(response):
                self.delegate?.witnessOk(response)
            case let .failure(error as NSError):
                self.delegate?.witnessErr(error)
            }
        }
    }
}

// MARK: - Profile
public extension OptableSDK {
    /**
     profile(traits, id, neighbors, completion) calls the Optable Sandbox Profile API to associate the provided
     traits (key-value pairs) with the user/device. You can optionally include a specific id and neighbor ids.

     On completion, the handler receives:
     - .success(OptableTargeting) on success
     - .failure(Error) on failure

     The resulting OptableTargeting is also cached for targetingFromCache().
     */
    func profile(traits: [String: Any], id: String? = nil, neighbors: [String]? = nil, _ completion: @escaping (Result<OptableTargeting, Error>) -> Void) throws {
        try _profile(traits: traits, id: id, neighbors: neighbors, completion: completion)
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `profile(traits, completion)` API.

     Instead of completion callbacks, results are returned via async/await.
     */
    @available(iOS 13.0, *)
    func profile(traits: [String: Any], id: String? = nil, neighbors: [String]? = nil) async throws -> OptableTargeting {
        return try await withCheckedThrowingContinuation({ [unowned self] continuation in
            do {
                try self._profile(traits: traits, id: id, neighbors: neighbors, completion: { continuation.resume(with: $0) })
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }

    // MARK: Objective-C support
    /**
     This is the Objective-C compatible version of the `profile(traits, completion)` API.

     Instead of completion callbacks, delegate methods are called.
     */
    @objc
    func profile(traits: [String: Any], id: String? = nil, neighbors: [String]? = nil) throws {
        try _profile(traits: traits, id: id, neighbors: neighbors, completion: { result in
            switch result {
            case let .success(response):
                self.delegate?.profileOk(response)
            case let .failure(error as NSError):
                self.delegate?.profileErr(error)
            }
        })
    }
}

// MARK: - Identify from URL
public extension OptableSDK {
    /**
     Attempts to extract an "oeid" query parameter from the given URL string and, if present,
     calls identify with that identifier.

     Use this when handling incoming universal links that may contain an "oeid"
     (for example, SHA256(lowercased(email)) embedded in campaign links).
     */
    @objc
    func tryIdentifyFromURL(_ urlString: String) throws {
        let eidStr = OptableIdentifierEncoder.eidFromURL(urlString)

        guard let eid = OptableIdentifier(extendedIdentifier: eidStr) else { return }

        try self._identify([eid], completion: { _ in /* no-op */ })
    }
}

// MARK: - Internal
extension OptableSDK {
    func _identify(_ ids: [OptableIdentifier], completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
        var ids = ids

        enrichIfNeeded(ids: &ids)

        guard let request = try api.identify(ids: ids) else {
            throw OptableError.identify("Failed to create identify request")
        }

        api.dispatch(request: request, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil, data != nil else {
                if let err = error {
                    completion(.failure(OptableError.identify("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.identify("Session error: Unknown")))
                }
                return
            }
            guard HTTPStatusCode(rawValue: response.statusCode)?.isSuccess == true else {
                let errDesc = OptableSDK.generateEdgeAPIErrorDescription(with: data, response: response)
                completion(.failure(OptableError.identify(errDesc, code: response.statusCode)))
                return
            }
            completion(.success(response))
        }).resume()
    }

    func _targeting(ids: [OptableIdentifier]?, completion: @escaping (Result<OptableTargeting, Error>) -> Void) throws {
        var ids = ids ?? []

        enrichIfNeeded(ids: &ids)

        guard let request = try api.targeting(ids: ids) else {
            throw OptableError.targeting("Failed to create targeting request")
        }

        api.dispatch(request: request, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil, data != nil else {
                if let err = error {
                    completion(.failure(OptableError.targeting("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.targeting("Session error: Unknown")))
                }
                return
            }
            guard HTTPStatusCode(rawValue: response.statusCode)?.isSuccess == true else {
                let errDesc = OptableSDK.generateEdgeAPIErrorDescription(with: data, response: response)
                completion(.failure(OptableError.targeting(errDesc, code: response.statusCode)))
                return
            }

            do {
                let optableTargeting = try OptableSDK.generateOptableTargeting(from: data)

                /// We cache the latest targeting result in client storage for targetingFromCache() users:
                self.api.storage.setTargeting(optableTargeting)

                completion(.success(optableTargeting))
            } catch {
                completion(.failure(OptableError.targeting("Error parsing JSON response: \(error)")))
            }
        }).resume()
    }

    func _witness(event: String, properties: [String: Any], completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
        guard let request = try api.witness(event: event, properties: properties) else {
            throw OptableError.witness("Failed to create witness request")
        }

        api.dispatch(request: request, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                if let err = error {
                    completion(.failure(OptableError.witness("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.witness("Session error: Unknown")))
                }
                return
            }
            guard HTTPStatusCode(rawValue: response.statusCode)?.isSuccess == true else {
                let errDesc = OptableSDK.generateEdgeAPIErrorDescription(with: data, response: response)
                completion(.failure(OptableError.witness(errDesc, code: response.statusCode)))
                return
            }
            completion(.success(response))
        }).resume()
    }

    func _profile(traits: [String: Any], id: String?, neighbors: [String]?, completion: @escaping (Result<OptableTargeting, Error>) -> Void) throws {
        guard let request = try api.profile(traits: traits, id: id, neighbors: neighbors) else {
            throw OptableError.profile("Failed to create profile request")
        }

        api.dispatch(request: request, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                if let err = error {
                    completion(.failure(OptableError.profile("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.profile("Session error: Unknown")))
                }
                return
            }
            guard HTTPStatusCode(rawValue: response.statusCode)?.isSuccess == true else {
                let errDesc = OptableSDK.generateEdgeAPIErrorDescription(with: data, response: response)
                completion(.failure(OptableError.profile(errDesc, code: response.statusCode)))
                return
            }

            do {
                let optableTargeting = try OptableSDK.generateOptableTargeting(from: data)

                /// We cache the latest targeting result in client storage for targetingFromCache() users:
                self.api.storage.setTargeting(optableTargeting)

                completion(.success(optableTargeting))
            } catch {
                completion(.failure(OptableError.profile("Error parsing JSON response: \(error)")))
            }
        }).resume()
    }

    func enrichIfNeeded(ids: inout [OptableIdentifier]) {
        // Enrich with Apple IDFA
        if config.skipAdvertisingIdDetection == false,
           ATT.advertisingIdentifierAvailable,
           ATT.advertisingIdentifier != UUID(uuid: uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)) {
            let systemIDFA = ATT.advertisingIdentifier.uuidString

            var idfaMatchingSystemIdxs: [Int] = []

            for idx in ids.indices {
                if case let .appleIDFA(value) = ids[idx] {
                    if value == systemIDFA {
                        idfaMatchingSystemIdxs.append(idx)
                    }
                }
            }

            // Remove all matching systemIDFA (deduplicate)
            ids.removeCompat(atOffsets: IndexSet(idfaMatchingSystemIdxs))

            // Prepend all identifiers with systemIDFA
            ids.insert(.appleIDFA(systemIDFA), at: ids.startIndex)
        }
    }

    static func generateEdgeAPIErrorDescription(with data: Data?, response: HTTPURLResponse) -> String {
        var msg = "HTTP response.statusCode: \(response.statusCode)"
        do {
            let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
            msg += ", data: \(json)"
        } catch {}
        return msg
    }

    static func generateGAMTargetingKeywords(from targetingData: NSDictionary?) -> NSDictionary? {
        guard
            let targetingData,
            (targetingData as Dictionary).isEmpty == false,
            let audienceData = targetingData["audience"] as? [NSDictionary]
        else { return nil }

        let gamTargetingKeywords = NSMutableDictionary()

        for audience in audienceData {
            if let keyspace = audience["keyspace"] as? String, let ids = audience["ids"] as? [[String: String]] {
                gamTargetingKeywords[keyspace] = ids.compactMap(\.values.first).joined(separator: ",")
            }
        }

        return gamTargetingKeywords
    }

    static func generateORTB2Config(from targetingData: NSDictionary?) -> String? {
        guard
            let targetingData,
            (targetingData as Dictionary).isEmpty == false,
            let ortbConfig = targetingData["ortb2"] as? NSDictionary,
            let ortbJSONData = try? JSONSerialization.data(withJSONObject: ortbConfig, options: []),
            let ortbJSONString = String(data: ortbJSONData, encoding: .utf8)
        else { return nil }
        return ortbJSONString
    }

    static func generateOptableTargeting(from responseData: Data?) throws -> OptableTargeting {
        guard let responseData else {
            return OptableTargeting(optableTargeting: [:])
        }

        let optableTargetingData = try JSONSerialization.jsonObject(with: responseData, options: [])
        let optableTargetingDict: NSMutableDictionary = ((optableTargetingData as? NSDictionary)?.mutableCopy() as? NSMutableDictionary) ?? NSMutableDictionary()
        let optableTargeting = OptableTargeting(
            optableTargeting: optableTargetingDict as? [String: Any] ?? [:],
            gamTargetingKeywords: OptableSDK.generateGAMTargetingKeywords(from: optableTargetingDict) as? [String : Any],
            ortb2: OptableSDK.generateORTB2Config(from: optableTargetingDict)
        )

        return optableTargeting
    }
}
