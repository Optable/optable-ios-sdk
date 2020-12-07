//
//  Config.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

struct Config {
    var host: String
    var app: String
    var insecure: Bool
    var useragent: String?

    func edgeURL(_ path: String) -> URL? {
        var proto = "https://"
        if self.insecure {
            proto = "http://"
        }

        var components = URLComponents(string: proto + self.host + "/" + self.app + "/" + path)!
        components.queryItems = [ URLQueryItem(name: "osdk", value: OptableSDK.version) ]
        return components.url
    }
}
