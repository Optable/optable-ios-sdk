//
//  OptableSDK.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation
import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif
import AppTrackingTransparency
import AdSupport

//
//  OptableDelegate is a delegate protocol that the caller may optionally use. Swift applications can choose to integrate using
//  callbacks or the delegator pattern, whereas Objective-C apps must use the delegator pattern.
//
//  The OptableDelegate protocol consists of implementing *Ok() and *Err() event handlers. The *Ok() handler will
//  receive an NSDictionary when the delegate variant of the targeting() API is called, and an HTTPURLResponse in all other
//  SDK APIs that do not return actual data on success (e.g., identify(), witness(), etc.)
//
//  The *Err() handlers will be called with an NSError instance on SDK API errors.
//
//  Finally note that for the delegate variant of SDK API methods, internal exceptions will result in setting the NSError
//  object passed which is passed by reference to the method, and not calling the delegate.
//
@objc
public protocol OptableDelegate {
    func initiateOk(_ result: HTTPURLResponse)
    func initiateErr(_ error: NSError)
    func identifyOk(_ result: HTTPURLResponse)
    func identifyErr(_ error: NSError)
    func profileOk(_ result: HTTPURLResponse)
    func profileErr(_ error: NSError)
    func targetingOk(_ result: NSDictionary)
    func targetingErr(_ error: NSError)
    func witnessOk(_ result: HTTPURLResponse)
    func witnessErr(_ error: NSError)
}

//
//  OptableSDK exposes an API that is used by an iOS app developer integrating with an Optable Sandbox.
//
//  An instance of OptableSDK refers to an Optable Sandbox specified by the caller via `host` and `app` arguments provided to the constructor.
//
//  It is possible to create multiple instances of OptableSDK, should the developer want to integrate with multiple Sandboxes.
//
//  The OptableSDK keeps some state in UserDefaults (https://developer.apple.com/documentation/foundation/userdefaults), a key/value store persisted
//  across launches of the app.  The state is therefore unique to the app+device, and not globally unique to the app across devices.
//
@objc
public class OptableSDK: NSObject {
    @objc public var delegate: OptableDelegate?

    public enum OptableError: Error {
        case initiate(String)
        case identify(String)
        case profile(String)
        case targeting(String)
        case witness(String)
    }

    var config: Config
    var client: Client

    //
    //  OptableSDK(host, app) returns an instance of the SDK configured to talk to the sandbox specified by host & app:
    //
    @objc
    public init(host: String, app: String, insecure: Bool = false, useragent: String? = nil, initPassport: Bool = true) {
        self.config = Config(host: host, app: app, insecure: insecure, useragent: useragent, initPassport: initPassport)
        self.client = Client(self.config)
        super.init()
        if self.config.initPassport {
            do {
                try self.initiate() { result in
                    switch result {
                    case .success(let response):
                        print("[OptableSDK] Success on /init API call: response.statusCode = \(response.statusCode)")
                    case .failure(let error):
                        print("[OptableSDK] Error on /init API call: \(error)")
                    }
                }
            } catch {
                print("[OptableSDK] Exception: \(error)")
            }
        }
    }

    @objc
    public func getPassport() -> String {
        if self.client.storage.getPassport() == nil {
            return "None"
        }
        return self.client.storage.getPassport()!
    }
    
    //
    //  initiate(completion) issues a call to the Optable Sandbox "init" API, writing a passport to LocalStorage.
    //  It is asynchronous, and on completion it will call the specified completion handler, passing
    //  it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func initiate(_ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        try Init(config: self.config, client: self.client) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil, data != nil else {
                if let err = error {
                    completion(.failure(OptableError.identify("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.identify("Session error: Unknown")))
                }
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.initiate(msg)))
                return
            }
            completion(.success(response))
        }?.resume()
    }
    
    //
    //  initiate() is the "delegate variant" of the identify(ids, completion) method. It wraps the latter with
    //  a delegator callback.
    //
    //  This is the Objective-C compatible version of the initiate(completion) API.
    //
    @objc
    public func initiate() throws -> Void {
        try self.initiate() { result in
            switch result {
            case .success(let response):
                self.delegate?.initiateOk(response)
            case .failure(let error as NSError):
                self.delegate?.initiateErr(error)
            }
        }
    }
    
    //
    //  identify(ids, completion) issues a call to the Optable Sandbox "identify" API, passing the specified
    //  list of type-prefixed IDs. It is asynchronous, and on completion it will call the specified completion handler, passing
    //  it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func identify(ids: [String], _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        try Identify(config: self.config, client: self.client, ids: ids) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil, data != nil else {
                if let err = error {
                    completion(.failure(OptableError.identify("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.identify("Session error: Unknown")))
                }
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.identify(msg)))
                return
            }
            completion(.success(response))
        }?.resume()
    }

    //
    //  identify(ids) is the "delegate variant" of the identify(ids, completion) method. It wraps the latter with
    //  a delegator callback.
    //
    //  This is the Objective-C compatible version of the identify(ids, completion) API.
    //
    @objc
    public func identify(_ ids: [String]) throws -> Void {
        try self.identify(ids: ids) { result in
            switch result {
            case .success(let response):
                self.delegate?.identifyOk(response)
            case .failure(let error as NSError):
                self.delegate?.identifyErr(error)
            }
        }
    }

    //
    //  identify(email, aaid, ppid, completion) issues a call to the Optable Sandbox "identify" API, passing it the SHA-256
    //  of the caller-provided 'email' and, when specified via the 'aaid' Boolean, the Apple ID For Advertising (IDFA)
    //  associated with the device. When 'ppid' is provided as a string, it is also sent for identity resolution.
    //
    //  The identify method is asynchronous, and on completion it will call the specified completion handler, passing
    //  it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func identify(email: String, aaid: Bool = false, ppid: String = "", _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        var ids = [String]()

        if (email != "") {
            ids.append(self.eid(email))
        }

        if aaid {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    if status == .authorized {
                        ids.append(self.aaid(ASIdentifierManager.shared().advertisingIdentifier.uuidString))
                    }
                })
            } else {
                if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                    ids.append(self.aaid(ASIdentifierManager.shared().advertisingIdentifier.uuidString))
                }
            }
        }

        if ppid.count > 0 {
            ids.append(self.cid(ppid))
        }

        try self.identify(ids: ids, completion)
    }

    //
    //  identify(email, aaid, ppid) is the "delegate variant" of the identify(email, aaid, ppid, completion) method.
    //  It wraps the latter with a delegator callback.
    //
    //  This is the Objective-C compatible version of the identify(email, aaid, ppid, completion) API.
    //
    @objc
    public func identify(_ email: String, aaid: Bool = false, ppid: String = "") throws -> Void {
        try self.identify(email: email, aaid: aaid, ppid: ppid) { result in
            switch result {
            case .success(let response):
                self.delegate?.identifyOk(response)
            case .failure(let error as NSError):
                self.delegate?.identifyErr(error)
            }
        }
    }

    //
    //  targeting(completion) calls the Optable Sandbox "targeting" API, which returns the key-value targeting
    //  data matching the user/device/app.
    //
    //  The targeting method is asynchronous, and on completion it will call the specified completion handler,
    //  passing it either the NSDictionary targeting data on success, or an OptableError on failure.
    //
    //  On success, this method will also cache the resulting targeting data in client storage, which can
    //  be access using targetingFromCache(), and cleared using targetingClearCache().
    //
    public func targeting(_ completion: @escaping (Result<NSDictionary,OptableError>) -> Void) throws -> Void {
        try Targeting(config: self.config, client: self.client) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil, data != nil else {
                if let err = error {
                    completion(.failure(OptableError.targeting("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.targeting("Session error: Unknown")))
                }
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.targeting(msg)))
                return
            }

            do {
                let keyvalues = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                let result = keyvalues as? NSDictionary ?? NSDictionary()

                // We cache the latest targeting result in client storage for targetingFromCache() users:
                self.client.storage.setTargeting(keyvalues as? [String: Any] ?? [String: Any]())

                completion(.success(result))
            } catch {
                completion(.failure(OptableError.targeting("Error parsing JSON response: \(error)")))
            }
        }?.resume()
    }

    //
    //  targeting() is the "delegate variant" of the targeting(completion) method. It wraps the latter with
    //  a delegator callback.
    //
    //  This is the Objective-C compatible version of the targeting(completion) API.
    //
    @objc
    public func targeting() throws -> Void {
        try self.targeting() { result in
            switch result {
            case .success(let keyvalues):
                self.delegate?.targetingOk(keyvalues)
            case .failure(let error as NSError):
                self.delegate?.targetingErr(error)
            }
        }
    }

    //
    //  targetingFromCache() returns the previously cached targeting data, if any.
    //
    @objc
    public func targetingFromCache() -> NSDictionary? {
        guard let keyvalues = self.client.storage.getTargeting() as NSDictionary? else {
            return nil
        }
        return keyvalues
    }

    //
    //  targetingClearCache() clears any previously cached targeting data.
    //
    @objc
    public func targetingClearCache() -> Void {
        self.client.storage.clearTargeting()
    }

    //
    //  witness(event, properties, completion) calls the Optable Sandbox "witness" API in order to log
    //  a specified 'event' (e.g., "app.screenView", "ui.buttonPressed"), with the specified keyvalue
    //  NSDictionary 'properties', which can be subsequently used for audience assembly.
    //
    //  The witness method is asynchronous, and on completion it will call the specified completion handler,
    //  passing it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func witness(event: String, properties: NSDictionary, _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        try Witness(config: self.config, client: self.client, event: event, properties: properties) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                if let err = error {
                    completion(.failure(OptableError.witness("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.witness("Session error: Unknown")))
                }
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.witness(msg)))
                return
            }
            completion(.success(response))
        }?.resume()
    }

    //
    //  witness(event, properties) is the "delegate variant" of the witness(event, properties, completion) method.
    //  It wraps the latter with a delegator callback.
    //
    //  This is the Objective-C compatible version of the witness(event, properties, completion) API.
    //
    @objc
    public func witness(_ event: String, properties: NSDictionary) throws -> Void {
        try self.witness(event: event, properties: properties) { result in
            switch result {
            case .success(let response):
                self.delegate?.witnessOk(response)
            case .failure(let error as NSError):
                self.delegate?.witnessErr(error)
            }
        }
    }

    //
    //  profile(traits, completion) calls the Optable Sandbox "profile" API in order to associate
    //  specified 'traits' (i.e., key-value pairs) with the user's device. The specified
    //  NSDictionary 'traits' can be subsequently used for audience assembly.
    //
    //  The profile method is asynchronous, and on completion it will call the specified completion handler,
    //  passing it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func profile(traits: NSDictionary, _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        try Profile(config: self.config, client: self.client, traits: traits) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                if let err = error {
                    completion(.failure(OptableError.profile("Session error: \(err)")))
                } else {
                    completion(.failure(OptableError.profile("Session error: Unknown")))
                }
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.profile(msg)))
                return
            }
            completion(.success(response))
        }?.resume()
    }

    //
    //  profile(traits) is the "delegate variant" of the profile(traits, completion) method.
    //  It wraps the latter with a delegator callback.
    //
    //  This is the Objective-C compatible version of the profile(traits, completion) API.
    //
    @objc
    public func profile(traits: NSDictionary) throws -> Void {
        try self.profile(traits: traits) { result in
            switch result {
            case .success(let response):
                self.delegate?.profileOk(response)
            case .failure(let error as NSError):
                self.delegate?.profileErr(error)
            }
        }
    }

    //
    //  eid(email) is a helper that returns type-prefixed SHA256(downcase(email))
    //
    @objc
    public func eid(_ email: String) -> String {
        let pfx = "e:"
        let normEmail = Data(email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).utf8)

        #if canImport(CryptoKit)
            if #available(iOS 13.0, *) {
                return pfx + SHA256.hash(data: normEmail).compactMap {
                    String(format: "%02x", $0)
                }.joined()
            } else {
                return pfx + self.cchash(normEmail)
            }
        #else
            return pfx + self.cchash(normEmail)
        #endif
    }

    @objc
    private func cchash(_ input: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        input.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(input.count), &digest)
        }
        return digest.makeIterator().compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    //
    //  aaid(idfa) is a helper that returns the type-prefixed Apple ID For Advertising
    //
    @objc
    public func aaid(_ idfa: String) -> String {
        return "a:" + idfa.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    //
    //  cid(ppid) is a helper that returns custom type-prefixed origin-provided PPID
    //
    @objc
    public func cid(_ ppid: String) -> String {
        return "c:" + ppid.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    //
    //  eidFromURL(urlString) is a helper that returns a type-prefixed ID based on
    //  the query string oeid=sha256value parameter in the specified urlString, if
    //  one is found. Otherwise, it returns an empty string.
    //
    //  The use for this is when handling incoming universal links which might
    //  contain an "oeid" value with the SHA256(downcase(email)) of a user, such as
    //  encoded links in newsletter Emails sent by the application developer. Such
    //  hashed Email values can be used in calls to identify()
    //
    @objc
    public func eidFromURL(_ urlString: String) -> String {
        guard let url = URL(string: urlString) else { return "" }
        guard let urlc = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return "" }
        guard let urlqis = urlc.queryItems else { return "" }

        // Look for an oeid parameter in the urlString:
        var oeid = ""
        for qi: URLQueryItem in urlqis {
            guard let val = qi.value else {
                continue
            }
            if qi.name.lowercased() == "oeid" {
                oeid = val
                break
            }
        }

        // Check that oeid looks like a valid SHA256:
        let range = NSRange(location: 0, length: oeid.utf16.count)
        guard let regex = try? NSRegularExpression(pattern: "[a-f0-9]{64}", options: .caseInsensitive) else { return "" }
        if (oeid.count != 64) || (regex.firstMatch(in: oeid, options: [], range: range) == nil) {
            return ""
        }

        return "e:" + oeid.lowercased()
    }

    //
    //  tryIdentifyFromURL(urlString) is a helper that attempts to find a valid-looking
    //  "oeid" parameter in the specified urlString's query string parameters and, if found,
    //  calls self.identify([oeid]).
    //
    //  The use for this is when handling incoming universal links which might contain an
    //  "oeid" value with the SHA256(downcase(email)) of an incoming user, such as encoded
    //  links in newsletter Emails sent by the application developer.
    //
    @objc
    public func tryIdentifyFromURL(_ urlString: String) throws -> Void {
        let oeid = self.eidFromURL(urlString)

        if (oeid.count > 0) {
            try self.identify(ids: [oeid]) { _ in /* no-op */ }
        }
    }

    //
    //  OptableSDK.version returns the SDK version as a String. The version is based on the short
    //  version string set in the SDK project CFBundleShortVersionString. When the SDK is included via
    //  Cocoapods, it will be set automatically on `pod install` according to the podspec version.
    //
    public static var version: String {
        guard let version = Bundle(for: OptableSDK.self).infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "ios-unknown"
        }
        return "ios-" + version
    }
}
