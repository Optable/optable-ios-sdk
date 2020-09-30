//
//  Client.swift
//  OptableSDK
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation
import WebKit

class Client {
    let passportHeader: String = "X-Optable-Visitor"
    var storage: LocalStorage
    var ua: String?

    init(_ config: Config) {
        self.storage = LocalStorage(config)
        self.userAgent { (realUserAgent) in
            self.ua = realUserAgent
        }
    }

    func dispatchRequest(_ req: URLRequest, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard let res = response as? HTTPURLResponse, error == nil else {
                completionHandler(data, response, error)
                return
            }
            guard 200 ..< 300 ~= res.statusCode else {
                completionHandler(data, response, error)
                return
            }
            if let passport = res.value(forHTTPHeaderField: self.passportHeader) {
                self.storage.setPassport(passport)
            }
            completionHandler(data, response, error)
        }
    }

    func postRequest(url: URL, data: Any) throws -> URLRequest? {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        let reqBodyJSON = try JSONSerialization.data(withJSONObject: data, options: [])
        req.httpBody = reqBodyJSON

        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        if let passport: String = self.storage.getPassport() {
            req.addValue(passport, forHTTPHeaderField: self.passportHeader)
        }

        if self.ua != nil {
            req.addValue(self.ua!, forHTTPHeaderField: "User-Agent")
        }

        return req
    }
    
    func getRequest(url: URL) throws -> URLRequest? {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        if let passport: String = self.storage.getPassport() {
            req.addValue(passport, forHTTPHeaderField: self.passportHeader)
        }

        if self.ua != nil {
            req.addValue(self.ua!, forHTTPHeaderField: "User-Agent")
        }

        return req
    }

    func userAgent(callback: @escaping(_ useragent: String) -> Void) {
        var wkUserAgent: String = ""
        let myGroup = DispatchGroup()
        let window = UIApplication.shared.keyWindow
        let webView = WKWebView(frame: UIScreen.main.bounds)

        webView.isHidden = true
        window?.addSubview(webView)
        myGroup.enter()

        webView.loadHTMLString("<html></html>", baseURL: nil)
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: { (userAgent: Any?, error: Error?) in
            if let userAgent = userAgent as? String {
                wkUserAgent = userAgent
            }
            webView.stopLoading()
            webView.removeFromSuperview()
            myGroup.leave()
        })
        myGroup.notify(queue: .main) {
            callback(wkUserAgent)
        }
    }
}
