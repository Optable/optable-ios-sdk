//
//  Witness.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies, Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

func Witness(config: Config, client: Client, event: String, properties: NSDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
    guard let url = config.edgeURL("witness") else { return nil }
    let req = try client.postRequest(url: url, data: ["event": event, "properties": properties])
    return client.dispatchRequest(req, completionHandler)
}
