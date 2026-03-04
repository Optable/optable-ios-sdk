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
 OptableDelegate is a delegate protocol that the caller may optionally use.
 Swift applications can choose to integrate using callbacks or the delegator pattern, whereas Objective-C apps must use the delegator pattern.

 The OptableDelegate protocol consists of implementing *Ok() and *Err() event handlers.
 The *Ok() handler will receive an NSDictionary when the delegate variant of the targeting() API is called,
 and an HTTPURLResponse in all other SDK APIs that do not return actual data on success (e.g., identify(), witness(), etc.)

 The *Err() handlers will be called with an NSError instance on SDK API errors.

 Finally note that for the delegate variant of SDK API methods, internal exceptions will result in setting the NSError object passed which is passed by reference to the method, and not calling the delegate.
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

 An instance of OptableSDK refers to an Optable Sandbox specified by the caller via `host` and `app` arguments provided to the constructor.

 It is possible to create multiple instances of OptableSDK, should the developer want to integrate with multiple Sandboxes.

 The OptableSDK keeps some state in UserDefaults (https:///developer.apple.com/documentation/foundation/userdefaults), a key/value store persisted across launches of the app.  The state is therefore unique to the app+device, and not globally unique to the app across devices.
 */
@objc
public class OptableSDK: NSObject {
    @objc
    public var delegate: OptableDelegate?

    let config: OptableConfig
    let api: EdgeAPI

    /// `OptableSDK` returns an instance of the SDK configured to use the sandbox specified by `OptableConfig`:
    @objc
    public init(config: OptableConfig) {
        self.config = config
        self.api = EdgeAPI(config)

        // Automatically request Tracking Authorization
        if #available(iOS 14, *) {
            if config.skipAdvertisingIdDetection == false, ATT.canAuthorize {
                ATT.requestATTAuthorization()
            }
        }
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
     identify(ids, completion) issues a call to the Optable Sandbox "identify" API, passing the specified list of type-prefixed IDs.

     It is asynchronous, and on completion it will call the specified completion handler, passing
     it either the HTTPURLResponse on success, or an NSError on failure.

     ```swift
     // Example
     optableSDK.identify([.emailAddress("example@example.com"), .phoneNumber("1234567890")], completion: completion)
     ```
     */
    func identify(_ ids: [OptableIdentifier], completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
        try _identify(ids, completion: completion)
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `identify(ids, completion)` API.

     Instead of completion callbacks, function have to be awaited.
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

    // MARK: Objective-C support
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
}

// MARK: - Targeting
public extension OptableSDK {
    /**
     targeting(completion) calls the Optable Sandbox "targeting" API, which returns the key-value targeting data matching the user/device/app.

     The targeting method is asynchronous, and on completion it will call the specified completion handler,
     passing it either the NSDictionary targeting data on success, or an NSError on failure.

     On success, this method will also cache the resulting targeting data in client storage, which can
     be access using targetingFromCache(), and cleared using targetingClearCache().

     ```swift
     // Example
     optableSDK.targeting([.emailAddress("example@example.com"), .phoneNumber("1234567890")], completion: completion)
     ```
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

     Instead of completion callbacks, function have to be awaited.
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

    // MARK: Objective-C support
    /**
     This is the Objective-C compatible version of the `targeting(completion)` API.

     Instead of completion callbacks, delegate methods are called.
     */
    @objc
    func targeting(_ ids: [OptableSDKIdentifier]) throws {
        let bridgedIds = ids.compactMap({ OptableIdentifier(objc: $0) })
        try self._targeting(ids: bridgedIds, completion: { result in
            switch result {
            case let .success(optableTargeting):
                self.delegate?.targetingOk(optableTargeting)
            case let .failure(error as NSError):
                self.delegate?.targetingErr(error)
            }
        })
    }
}

// MARK: - Witness
public extension OptableSDK {
    /**
     witness(event, properties, completion) calls the Optable Sandbox "witness" API in order to log a specified 'event' (e.g., "app.screenView", "ui.buttonPressed"), with the specified keyvalue NSDictionary 'properties', which can be subsequently used for audience assembly.

     The witness method is asynchronous, and on completion it will call the specified completion handler,
     passing it either the HTTPURLResponse on success, or an NSError on failure.
     */
    func witness(event: String, properties: NSDictionary, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
        try _witness(event: event, properties: properties, completion: completion)
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `witness(event, properties, completion)` API.

     Instead of completion callbacks, function have to be awaited.
     */
    @available(iOS 13.0, *)
    func witness(event: String, properties: NSDictionary) async throws -> HTTPURLResponse {
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
    func witness(event: String, properties: NSDictionary) throws {
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
     profile(traits, completion) calls the Optable Sandbox "profile" API in order to associate specified 'traits' (i.e., key-value pairs) with the user's device.

     The specified NSDictionary 'traits' can be subsequently used for audience assembly.
     The profile method is asynchronous, and on completion it will call the specified completion handler, passing it either the HTTPURLResponse on success, or an NSError on failure.
     */
    func profile(traits: NSDictionary, id: String? = nil, neighbors: [String]? = nil, completion: @escaping (Result<OptableTargeting, Error>) -> Void) throws {
        try _profile(traits: traits, id: id, neighbors: neighbors, completion: completion)
    }

    // MARK: Async/Await support
    /**
     This is the Swift Concurrency compatible version of the `profile(traits, completion)` API.

     Instead of completion callbacks, function have to be awaited.
     */
    @available(iOS 13.0, *)
    func profile(traits: NSDictionary, id: String? = nil, neighbors: [String]? = nil) async throws -> OptableTargeting {
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
    func profile(traits: NSDictionary, id: String? = nil, neighbors: [String]? = nil) throws {
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
    ///
    ///  tryIdentifyFromURL(urlString) is a helper that attempts to find a valid-looking
    ///  "oeid" parameter in the specified urlString's query string parameters and, if found,
    ///  calls self.identify([oeid]).
    ///
    ///  The use for this is when handling incoming universal links which might contain an
    ///  "oeid" value with the SHA256(downcase(email)) of an incoming user, such as encoded
    ///  links in newsletter Emails sent by the application developer.
    ///
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

    func _witness(event: String, properties: NSDictionary, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) throws {
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

    func _profile(traits: NSDictionary, id: String?, neighbors: [String]?, completion: @escaping (Result<OptableTargeting, Error>) -> Void) throws {
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

            var idfaIdxs: [Int] = []
            var idfaMatchingSystemIdxs: [Int] = []

            for idx in ids.indices {
                if case let .appleIDFA(value) = ids[idx] {
                    idfaIdxs.append(idx)
                    if value == systemIDFA {
                        idfaMatchingSystemIdxs.append(idx)
                    }
                }
            }

            // Remove all matching systemIDFA (deduplicate)
            ids.removeCompat(atOffsets: IndexSet(idfaMatchingSystemIdxs))

            // Prepend all identifiers with systemIDFA
            ids.insert(.appleIDFA(systemIDFA), at: ids.startIndex)

            // TODO: [high] Resolve should remove all others idfa not matching systemIDFA?
            // ids.removeCompat(atOffsets: IndexSet(idfaIdxs).subtracting(IndexSet(idfaMatchingSystemIdxs)))
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
            optableTargeting: optableTargetingDict,
            gamTargetingKeywords: OptableSDK.generateGAMTargetingKeywords(from: optableTargetingDict),
            ortb2: OptableSDK.generateORTB2Config(from: optableTargetingDict)
        )

        return optableTargeting
    }
}
