//
//  EdgeAPI.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
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
    func identify(ids: [OptableIdentifier]) throws -> URLRequest? {
        guard let url = buildEdgeAPIURL(endpoint: "identify") else { return nil }
        let jsonData = try jsonEncoder.encode(ids)
        let request = try buildRequest(.POST, url: url, headers: resolveHeaders(), data: jsonData)
        return request
    }

    func profile(traits: NSDictionary, id: String? = nil, neighbors: [String]? = nil) throws -> URLRequest? {
        guard let url = buildEdgeAPIURL(endpoint: "profile") else { return nil }

        var payload: [String: Any] = ["traits": traits]

        if let id {
            payload["id"] = id
        }

        if let neighbors, neighbors.isEmpty == false {
            payload["neighbors"] = neighbors
        }

        let request = try buildRequest(.POST, url: url, headers: resolveHeaders(), obj: payload)
        return request
    }

    func targeting(ids: [OptableIdentifier]) throws -> URLRequest? {
        guard var url = buildEdgeAPIURL(endpoint: "targeting") else { return nil }

        let queryItems = ids
            .compactMap({ $0.extendedIdentifier })
            .compactMap({ URLQueryItem(name: "id", value: $0) })
        url.compatAppend(queryItems: queryItems)

        let request = try buildRequest(.GET, url: url, headers: resolveHeaders())
        return request
    }

    func witness(event: String, properties: NSDictionary) throws -> URLRequest? {
        guard let url = buildEdgeAPIURL(endpoint: "witness") else { return nil }
        let request = try buildRequest(.POST, url: url, headers: resolveHeaders(), obj: ["event": event, "properties": properties])
        return request
    }
}

// MARK: - Dispatch
extension EdgeAPI {
    func dispatch(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { data, response, error in
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
}

// MARK: - Private
extension EdgeAPI {
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

    func resolveHeaders() -> HTTPHeaders {
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

        if let reg = config.reg {
            components.queryItems?.append(
                .init(name: "reg", value: reg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            )
        }

        if let gdprConsent = config.gdprConsent, let gdpr = config.gdpr?.boolValue {
            components.queryItems?.append(contentsOf: [
                .init(name: "gdpr_consent", value: gdprConsent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
                .init(name: "gdpr", value: "\(gdpr ? 1 : 0)"),
            ])
        } else if let globalGDPRConsent = IABConsent.gdprTC, let globalGDPR = IABConsent.gdprApplies {
            components.queryItems?.append(contentsOf: [
                .init(name: "gdpr_consent", value: globalGDPRConsent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
                .init(name: "gdpr", value: "\(globalGDPR ? 1 : 0)"),
            ])
        }

        if let gpp = config.gpp {
            components.queryItems?.append(
                .init(name: "gpp", value: gpp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            )
        } else if let globalGPP = IABConsent.gppTC {
            components.queryItems?.append(
                .init(name: "gpp", value: globalGPP.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            )
        }

        if let gppSid = config.gppSid {
            components.queryItems?.append(
                .init(name: "gpp_sid", value: gppSid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            )
        }

        return components.url
    }
}
