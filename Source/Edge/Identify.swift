//
//  Identify.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

func Identify(config: Config, client: Client, ids: [String], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
    guard let url = config.edgeURL("identify") else { return nil }
    let req = try client.postRequest(url: url, data: ids)
    return client.dispatchRequest(req, completionHandler)
}
