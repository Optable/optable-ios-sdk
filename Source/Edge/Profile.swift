//
//  Profile.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies, Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

func Profile(config: Config, client: Client, traits: NSDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
    let url = config.edgeURL("profile")
    let req = try client.postRequest(url: url!, data: ["traits": traits])
    return client.dispatchRequest(req!, completionHandler)
}
