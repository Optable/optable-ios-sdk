//
//  Init.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

func Init(config: Config, client: Client, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
    guard let url = config.edgeURL("init") else { return nil }
    let req = try client.postRequest(url: url, data: [])
    return client.dispatchRequest(req, completionHandler)
}
