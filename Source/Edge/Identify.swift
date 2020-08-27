//
//  Identify.swift
//  OptableSDK
//
//  Created by Bosko Milekic on 2020-08-18.
//  Copyright © 2020 Optable Technologies, Inc. All rights reserved.
//

import Foundation

func identifiers(type: String, pfx: String, ids: [String: Any]) -> [String] {
    var rids = [String]()
    if let idsk = ids[type] {
        if idsk is Array<String> {
            rids.append(contentsOf: (idsk as! Array<String>).map { pfx + $0 })
        } else if idsk is String {
            rids.append(pfx + (idsk as! String))
        }
    }
    return rids
}

func buildIdentifyRequest(config: Config, client: Client, ids: [String: Any]) throws -> URLRequest? {
    var rids = identifiers(type: "eid", pfx: "e:", ids: ids)
    rids.append(contentsOf: identifiers(type: "idfa", pfx: "a:", ids: ids))
    rids.append(contentsOf: identifiers(type: "gaid", pfx: "g:", ids: ids))

    let url = config.edgeURL("identify")
    guard let reqURL = url else { return nil; }

    let req = try client.postRequest(url: reqURL, data: rids)
    return req
}

func Identify(config: Config, client: Client, ids: [String: Any], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
    let req = try buildIdentifyRequest(config: config, client: client, ids: ids)
    return client.dispatchRequest(req!, completionHandler)
}
