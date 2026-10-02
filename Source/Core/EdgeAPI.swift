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
final class EdgeAPI: Sendable {
    private static let kPassportHeader: String = "X-Optable-Visitor"

    let storage: LocalStorage
    let config: OptableConfig

    /// The `User-Agent` sent with every request: `config.customUserAgent` when set, otherwise the WebView's
    /// user agent, resolved asynchronously on the main actor at init (nil until it arrives).
    var userAgent: String? {
        get { userAgentStore.withLock { $0 } }
        set { userAgentStore.withLock { $0 = newValue } }
    }

    private let userAgentStore: Locked<String?>

    private let jsonEncoder = JSONEncoder()

    init(_ config: OptableConfig) {
        self.config = config
        self.storage = LocalStorage(config)
        self.userAgentStore = Locked(config.customUserAgent)

        if config.customUserAgent == nil {
            let userAgentStore = self.userAgentStore
            Task { @MainActor in
                let realUserAgent = await EdgeAPI.resolveWebViewUserAgent()
                userAgentStore.withLock { $0 = realUserAgent }
            }
        }
    }

    // MARK: Endpoints
    func identify(ids: [OptableIdentifier]) throws -> URLRequest? {
        guard let url = buildEdgeAPIURL(endpoint: "identify") else { return nil }
        let jsonData = try jsonEncoder.encode(ids.filter({ $0.extendedIdentifier.isEmpty == false }))
        let request = try buildRequest(.POST, url: url, headers: resolveHeaders(), data: jsonData)
        return request
    }

    func profile(traits: [String: Any], id: String? = nil, neighbors: [String]? = nil) throws -> URLRequest? {
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

    func targeting(ids: [OptableIdentifier], hids: [OptableIdentifier]) throws -> URLRequest? {
        guard var url = buildEdgeAPIURL(endpoint: "targeting") else { return nil }

        var queryItems = ids
            .map({ $0.extendedIdentifier })
            .filter({ $0.isEmpty == false })
            .compactMap({ URLQueryItem(name: "id", value: $0) })
        
        let hidQueryItems = hids
            .compactMap({ $0.extendedIdentifier })
            .compactMap({ URLQueryItem(name: "hid", value: $0) })

        queryItems.append(contentsOf: hidQueryItems)

        if let bundle = Bundle.main.bundleIdentifier {
            queryItems.append(URLQueryItem(name: "bundle", value: bundle))
        }
        
        if let ver = Bundle.main.appVersionString {
            queryItems.append(URLQueryItem(name: "ver", value: ver))
        }
        
        if let userAgent {
            queryItems.append(URLQueryItem(name: "ua", value: userAgent))
        }
        
        if let id5Signature = storage.getID5Signature() {
            queryItems.append(URLQueryItem(name: "id5_signature", value: id5Signature))
        }

        url.compatAppend(queryItems: queryItems)

        let request = try buildRequest(.GET, url: url, headers: resolveHeaders())
        return request
    }

    func witness(event: String, properties: [String: Any]) throws -> URLRequest? {
        guard let url = buildEdgeAPIURL(endpoint: "witness") else { return nil }
        let request = try buildRequest(.POST, url: url, headers: resolveHeaders(), obj: ["event": event, "properties": properties])
        return request
    }
}

// MARK: - Dispatch
extension EdgeAPI {
    func dispatch(request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { [storage] data, response, error in
            guard let res = response as? HTTPURLResponse, error == nil else {
                completionHandler(data, response, error)
                return
            }
            guard 200 ..< 300 ~= res.statusCode else {
                completionHandler(data, response, error)
                return
            }
            if let passport = res.value(forHTTPHeaderField: Self.kPassportHeader) {
                storage.setPassport(passport)
            }
            completionHandler(data, response, error)
        }
    }
}

// MARK: - Private
extension EdgeAPI {
    /// Reads `navigator.userAgent` from a hidden, throwaway WKWebView attached to the key window.
    /// Returns an empty string when the WebView cannot provide one.
    @MainActor
    private static func resolveWebViewUserAgent() async -> String {
        let window = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
        let webView = WKWebView(frame: UIScreen.main.bounds)

        webView.isHidden = true
        window?.addSubview(webView)
        defer {
            webView.stopLoading()
            webView.removeFromSuperview()
        }

        webView.loadHTMLString("<html></html>", baseURL: nil)

        let userAgent = try? await webView.evaluateJavaScript("navigator.userAgent")
        return (userAgent as? String) ?? ""
    }

    func resolveHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers[.accept] = "application/json"
        headers[.contentType] = "application/json"

        if let userAgent {
            headers[.userAgent] = userAgent
        }

        if let origin = config.origin, origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            headers[.origin] = origin
        }

        if let apiKey = config.apiKey {
            headers[.authorization] = "Bearer \(apiKey)"
        }

        if let passport: String = storage.getPassport() {
            headers[Self.kPassportHeader] = passport
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
            .init(name: "t", value: config.tenant),
            .init(name: "o", value: config.originSlug),
            .init(name: "osdk", value: OptableSDK.version),
        ]

        if let reg = config.reg {
            components.queryItems?.append(.init(name: "reg", value: reg))
        }

        if let gdprConsent = config.gdprConsent, let gdpr = config.gdpr?.boolValue {
            components.queryItems?.append(contentsOf: [
                .init(name: "gdpr_consent", value: gdprConsent),
                .init(name: "gdpr", value: "\(gdpr ? 1 : 0)"),
            ])
        } else if let globalGDPRConsent = IABConsent.gdprTC, let globalGDPR = IABConsent.gdprApplies {
            components.queryItems?.append(contentsOf: [
                .init(name: "gdpr_consent", value: globalGDPRConsent),
                .init(name: "gdpr", value: "\(globalGDPR ? 1 : 0)"),
            ])
        }

        if let gpp = config.gpp {
            components.queryItems?.append(
                .init(name: "gpp", value: gpp)
            )
        } else if let globalGPP = IABConsent.gppTC {
            components.queryItems?.append(
                .init(name: "gpp", value: globalGPP)
            )
        }

        if let gppSid = config.gppSid {
            components.queryItems?.append(
                .init(name: "gpp_sid", value: gppSid)
            )
        }

        return components.url
    }
}
