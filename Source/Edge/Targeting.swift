//
//  Targeting.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies, Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

func Targeting(config: Config, client: Client, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
    let url = config.edgeURL("targeting")
    let req = try client.getRequest(url: url!)
    return client.dispatchRequest(req!, completionHandler)
}
