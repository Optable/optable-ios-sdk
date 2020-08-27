//
//  OptableSDK.swift
//  demo-ios-swift
//
//  Created by Bosko Milekic on 2020-08-06.
//  Copyright © 2020 Bosko Milekic. All rights reserved.
//

import Foundation

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
    //  identify(identifiers, completion) issues a call to the Optable Sandbox "identify" API, passing the specified
    //  dictionary of identifiers. It is asynchronous, and on completion it will call the specified completion handler, passing
    //  it either the HTTPURLResponse on success, or an OptableError on failure.
    //
    //  The input identifiers dictionary should have the following form:
    //  [
    //      "id_type": "id_value",
    //      "id_type": [ "id_value1", "id_value2", ... ]
    //      ...
    //  ]
    //
    //  The id types supported are: eid, idfa, gaid, and others. Refer to Optable's identify API documentation for details.
    //
    public func identify(_ identifiers: [String: Any], _ completion: @escaping (Result<HTTPURLResponse,OptableError>) -> Void) throws -> Void {
        try Identify(config: self.config, client: self.client, ids: identifiers) { (data, response, error) in
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
    //  targeting(completion) calls the Optable Sandbox "targeting" API, which returns the key-value targeting
    //  data matching the user/device/app. It is asynchronous, and on completion it will call the specified completion handler,
    //  passing it either the NSDictionary targeting data on success, or an OptablError on failure.
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
}
