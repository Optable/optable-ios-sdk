//
//  Config.swift
//  OptableSDK
//
//  Created by Bosko Milekic on 2020-08-18.
//  Copyright © 2020 Optable Technologies, Inc. All rights reserved.
//

import Foundation

struct Config {
    var host: String
    var app: String
    var insecure: Bool

    func edgeURL(_ path: String) -> URL? {
        var proto = "https://"
        if self.insecure {
            proto = "http://"
        }

        return URL(string: proto + self.host + "/" + self.app + "/" + path)
    }
}
