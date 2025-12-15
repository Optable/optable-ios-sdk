//
//  Edge.swift
//  OptableSDK
//
//  Created by user on 15.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation

enum Edge {
    static func profile(config: OptableConfig, client: Client, traits: NSDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = config.edgeURL("profile") else { return nil }
        let req = try client.postRequest(url: url, data: ["traits": traits])
        return client.dispatchRequest(req, completionHandler)
    }

    static func targeting(config: OptableConfig, client: Client, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = config.edgeURL("targeting") else { return nil }
        let req = try client.getRequest(url: url)
        return client.dispatchRequest(req, completionHandler)
    }

    static func identify(config: OptableConfig, client: Client, ids: [String], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = config.edgeURL("identify") else { return nil }
        let req = try client.postRequest(url: url, data: ids)
        return client.dispatchRequest(req, completionHandler)
    }

    static func witness(config: OptableConfig, client: Client, event: String, properties: NSDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = config.edgeURL("witness") else { return nil }
        let req = try client.postRequest(url: url, data: ["event": event, "properties": properties])
        return client.dispatchRequest(req, completionHandler)
    }
}
