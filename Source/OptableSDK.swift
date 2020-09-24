//
//  OptableSDK.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation
import CryptoKit
import AdSupport

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

public class OptableSDK: NSObject {

    public enum OptableError: Error {
        case identify(String)
        case targeting(String)
    }

    var config: Config
    var client: Client

    //
    //  OptableSDK(host, app) returns an instance of the SDK configured to talk to the sandbox specified by host & app:
    //
    public init(host: String, app: String, insecure: Bool = false) {
        self.config = Config(host: host, app: app, insecure: insecure)
        self.client = Client(self.config)
    }

    //
    //  identify(ids, completion) issues a call to the Optable Sandbox "identify" API, passing the specified
    //  list of type-prefixed IDs. It is asynchronous, and on completion it will call the specified completion handler, passing
    //  it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func identify(ids: [String], _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        try Identify(config: self.config, client: self.client, ids: ids) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                completion(.failure(OptableError.identify("Session error: \(error!)")))
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.identify(msg)))
                return
            }
            completion(.success(response))
        }.resume()
    }

    //
    //  identify(email, aaid, completion) issues a call to the Optable Sandbox "identify" API, passing it the SHA-256
    //  of the caller-provided 'email' and, when specified via the 'aaid' Boolean, the Apple ID For Advertising (IDFA)
    //  associated with the device. It is asynchronous, and on completion it will call the specified completion handler, passing
    //  it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    public func identify(email: String, aaid: Bool = false, _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        var ids = [String]()

        if (email != "") {
            ids.append("e:" + self.eid(email))
        }

        if aaid && ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            ids.append("a:" + ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        }

        try self.identify(ids: ids, completion)
    }

    //
    //  targeting(completion) calls the Optable Sandbox "targeting" API, which returns the key-value targeting
    //  data matching the user/device/app. It is asynchronous, and on completion it will call the specified completion handler,
    //  passing it either the NSDictionary targeting data on success, or an OptableError on failure.
    //
    public func targeting(_ completion: @escaping (Result<NSDictionary,OptableError>) -> Void) throws -> Void {
        try Targeting(config: self.config, client: self.client) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                completion(.failure(OptableError.targeting("Session error: \(error!)")))
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.targeting(msg)))
                return
            }

            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                completion(.success(result!))
            } catch {
                completion(.failure(OptableError.targeting("Error parsing JSON response: \(error)")))
            }
        }.resume()
    }

    //
    //  eid(email) is a helper that returns SHA256(downcase(email))
    //
    public func eid(_ email: String) -> String {
        return SHA256.hash(data: Data(email.lowercased().utf8)).compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    //
    //  OptableSDK.version returns the SDK version as a String. The version is based on the short version string set
    //  in the SDK project CFBundleShortVersionString. When the SDK is included via Cocoapods, it will be set
    //  automatically on `pod install` according to the podspec version.
    //
    public static var version: String {
        guard let version = Bundle(for: OptableSDK.self).infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "ios-unknown"
        }
        return "ios-" + version
    }
}
