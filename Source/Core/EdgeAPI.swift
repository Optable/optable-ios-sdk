//
//  EdgeAPI.swift
//  OptableSDK
//
//  Created by user on 15.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
//

import Foundation
import WebKit

// MARK: - EdgeAPI
/**
 Real Time API

 For more info check:
 [](https://docs.optable.co/optable-documentation/guides/real-time-api-integrations-guide)

 */
final class EdgeAPI {
    private let kPassportHeader: String = "X-Optable-Visitor"

    var storage: LocalStorage
    var config: OptableConfig

    var userAgent: String?

    private lazy var jsonEncoder = JSONEncoder()

    init(_ config: OptableConfig) {
        self.config = config
        self.storage = LocalStorage(config)
        if config.customUserAgent == nil {
            self.resolveUserAgent { realUserAgent in
                self.userAgent = realUserAgent
            }
        } else {
            self.userAgent = config.customUserAgent
        }
    }

    // MARK: Endpoints
    func identify(ids: OptableIdentifiers, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = buildEdgeAPIURL(endpoint:"identify") else { return nil }
        let jsonData = try jsonEncoder.encode(ids)
        let req = try buildRequest(.POST, url: url, headers: resolveHeaders(), data: jsonData)
        return dispatchRequest(req, completionHandler)
    }

    func profile(traits: NSDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = buildEdgeAPIURL(endpoint:"profile") else { return nil }
        let req = try buildRequest(.POST, url: url, headers: resolveHeaders(), obj: ["traits": traits])
        return dispatchRequest(req, completionHandler)
    }

    func targeting(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = buildEdgeAPIURL(endpoint:"targeting") else { return nil }
        let req = try buildRequest(.GET, url: url, headers: resolveHeaders())
        return dispatchRequest(req, completionHandler)
    }

    func witness(event: String, properties: NSDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask? {
        guard let url = buildEdgeAPIURL(endpoint:"witness") else { return nil }
        let req = try buildRequest(.POST, url: url, headers: resolveHeaders(), obj: ["event": event, "properties": properties])
        return dispatchRequest(req, completionHandler)
    }
}

// MARK: - Private
extension EdgeAPI {
    private func dispatchRequest(_ req: URLRequest, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: req) { data, response, error in
            guard let res = response as? HTTPURLResponse, error == nil else {
                completionHandler(data, response, error)
                return
            }
            guard 200 ..< 300 ~= res.statusCode else {
                completionHandler(data, response, error)
                return
            }
            if #available(iOS 13.0, *) {
                if let passport = res.value(forHTTPHeaderField: self.kPassportHeader) {
                    self.storage.setPassport(passport)
                }
            } else {
                // In older versions of iOS, we have to resort searching through headers via res.allHeaderFields
                // Unlike res.value(forHTTPHeaderField:...) which was introduced in iOS 13.0, allHeaderFields is
                // case-sensitive, so we need to take special care to perform a case-INsensitive search:
                for (key, value) in res.allHeaderFields {
                    if let header = key as? String {
                        let result: ComparisonResult = header.compare(self.kPassportHeader, options: NSString.CompareOptions.caseInsensitive)
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

    private func resolveUserAgent(callback: @escaping (_ useragent: String) -> Void) {
        var wkUserAgent = ""
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

    private func resolveHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers[.accept] = "application/json"
        headers[.contentType] = "application/json"

        if let userAgent {
            headers[.userAgent] = userAgent
        }

        if let apiKey = config.apiKey {
            headers[.authorization] = "Bearer \(apiKey)"
        }

        if let passport: String = storage.getPassport() {
            headers[kPassportHeader] = passport
        }

        return headers
    }

    private func buildRequest(_ method: HTTPMethod, url: URL, headers: HTTPHeaders, obj: Any? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let obj = obj {
            let reqBodyJSON = try JSONSerialization.data(withJSONObject: obj, options: [])
            request.httpBody = reqBodyJSON
        }

        for (key, value) in headers.asDict {
            request.addValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func buildRequest(_ method: HTTPMethod, url: URL, headers: HTTPHeaders, data: Data? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let data {
            request.httpBody = data
        }

        for (key, value) in headers.asDict {
            request.addValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    func buildEdgeAPIURL(endpoint: String) -> URL? {
        var components = URLComponents()
        components.scheme = config.insecure ? "http" : "https"
        components.host = config.host
        components.path = "/\(config.path)/\(endpoint)"
        components.queryItems = [
            .init(name: "t", value: config.tenant.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            .init(name: "o", value: config.originSlug.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            .init(name: "osdk", value: OptableSDK.version.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
        ]
        return components.url
    }
}
