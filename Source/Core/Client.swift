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
        if (config.useragent == nil) {
            self.userAgent { (realUserAgent) in
                self.ua = realUserAgent
            }
        } else {
            self.ua = config.useragent
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
            if #available(iOS 13.0, *) {
                if let passport = res.value(forHTTPHeaderField: self.passportHeader) {
                    self.storage.setPassport(passport)
                }
            } else {
                // In older versions of iOS, we have to resort searching through headers via res.allHeaderFields
                // Unlike res.value(forHTTPHeaderField:...) which was introduced in iOS 13.0, allHeaderFields is
                // case-sensitive, so we need to take special care to perform a case-INsensitive search:
                for (key, value) in res.allHeaderFields {
                    if let header = key as? String {
                        let result: ComparisonResult = header.compare(self.passportHeader, options: NSString.CompareOptions.caseInsensitive)
                        if result == .orderedSame {
                            if let pp = value as? String {
                                self.storage.setPassport(pp)
                                break
                            }
                        }
                    }
                }
            }
            completionHandler(data, response, error)
        }
    }

    func postRequest(url: URL, data: Any) throws -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        let reqBodyJSON = try JSONSerialization.data(withJSONObject: data, options: [])
        req.httpBody = reqBodyJSON

        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        if let passport: String = self.storage.getPassport() {
            req.addValue(passport, forHTTPHeaderField: self.passportHeader)
        }

        if let ua = self.ua {
            req.addValue(ua, forHTTPHeaderField: "User-Agent")
        }

        return req
    }
    
    func getRequest(url: URL) throws -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        if let passport: String = self.storage.getPassport() {
            req.addValue(passport, forHTTPHeaderField: self.passportHeader)
        }

        if let ua = self.ua {
            req.addValue(ua, forHTTPHeaderField: "User-Agent")
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
