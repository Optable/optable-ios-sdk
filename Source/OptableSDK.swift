//
//  OptableSDK.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation
import CryptoKit
import AppTrackingTransparency
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
        case witness(String)
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
    //  targeting(completion) calls the Optable Sandbox "targeting" API, which returns the key-value targeting
    //  data matching the user/device/app.
    //
    //  The targeting method is asynchronous, and on completion it will call the specified completion handler,
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
                completion(.failure(OptableError.witness("Session error: \(error!)")))
                return
            }
            guard 200 ..< 300 ~= response.statusCode else {
                var msg = "HTTP response.statusCode: \(response.statusCode)"
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    msg += ", data: \(json)"
                } catch {}
                completion(.failure(OptableError.witness(msg)))
                return
            }
            completion(.success(response))
        }.resume()
    }

    //
    //  eid(email) is a helper that returns type-prefixed SHA256(downcase(email))
    //
    public func eid(_ email: String) -> String {
        return "e:" + SHA256.hash(data: Data(email.lowercased().utf8)).compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    //
    //  aaid(idfa) is a helper that returns the type-prefixed Apple ID For Advertising
    //
    public func aaid(_ idfa: String) -> String {
        return "a:" + idfa.lowercased()
    }

    //
    //  cid(ppid) is a helper that returns custom type-prefixed origin-provided PPID
    //
    public func cid(_ ppid: String) -> String {
        return "c:" + ppid
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
