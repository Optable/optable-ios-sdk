//
//  Targeting.swift
//  OptableSDK
//
//  Created by Bosko Milekic on 2020-08-26.
//

import Foundation

func Targeting(config: Config, client: Client, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
    let url = config.edgeURL("targeting")
    let req = try client.getRequest(url: url!)
    return client.dispatchRequest(req!, completionHandler)
}
