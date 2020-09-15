//
//  Identify.swift
//  OptableSDK
//
//  Created by Bosko Milekic on 2020-08-18.
//  Copyright © 2020 Optable Technologies, Inc. All rights reserved.
//

import Foundation

func Identify(config: Config, client: Client, ids: [String], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
    let url = config.edgeURL("identify")
    let req = try client.postRequest(url: url!, data: ids)
    return client.dispatchRequest(req!, completionHandler)
}
