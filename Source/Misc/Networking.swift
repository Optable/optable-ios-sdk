//
//  Networking.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

// MARK: - HTTPMethod
enum HTTPMethod: String {
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case CONNECT
    case OPTIONS
    case TRACE
    case PATCH
}

// MARK: - HTTPHeader
enum HTTPHeader: String {
    // Content negotiation
    case accept = "Accept"
    case contentType = "Content-Type"
    case contentLength = "Content-Length"
    case contentEncoding = "Content-Encoding"

    // Authorization / security
    case authorization = "Authorization"
    case wwwAuthenticate = "WWW-Authenticate"
    case proxyAuthorization = "Proxy-Authorization"

    // Caching
    case cacheControl = "Cache-Control"
    case pragma = "Pragma"
    case expires = "Expires"
    case etag = "ETag"
    case ifNoneMatch = "If-None-Match"
    case ifModifiedSince = "If-Modified-Since"

    // Connection
    case connection = "Connection"
    case keepAlive = "Keep-Alive"
    case upgrade = "Upgrade"

    // User / client info
    case userAgent = "User-Agent"
    case referer = "Referer"
    case origin = "Origin"
    case host = "Host"

    // Cookies
    case cookie = "Cookie"
    case setCookie = "Set-Cookie"

    // Range / transfer
    case range = "Range"
    case acceptRanges = "Accept-Ranges"
    case transferEncoding = "Transfer-Encoding"

    // CORS
    case accessControlAllowOrigin = "Access-Control-Allow-Origin"
    case accessControlAllowMethods = "Access-Control-Allow-Methods"
    case accessControlAllowHeaders = "Access-Control-Allow-Headers"
    case accessControlExposeHeaders = "Access-Control-Expose-Headers"
    case accessControlAllowCredentials = "Access-Control-Allow-Credentials"
    case accessControlMaxAge = "Access-Control-Max-Age"

    // Compression
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
}

// MARK: - HTTPHeaders
struct HTTPHeaders {
    private var dict: [String: String] = [:]

    var asDict: [String: String] { dict }

    init() {}

    init(_ dict: [String: String]) {
        self.dict = dict
    }

    subscript(_ key: HTTPHeader) -> String? {
        get { dict[key.rawValue] }
        set { dict[key.rawValue] = newValue }
    }

    subscript(_ key: String) -> String? {
        get { dict[key] }
        set { dict[key] = newValue }
    }
}

// MARK: - HTTPQuery
enum HTTPQuery {
    case jsonObject(Encodable)
    case dict([String: String?])
}

// MARK: - HTTPBody
enum HTTPBody {
    case jsonObject(Encodable)
    case jsonArray([Any])
    case jsonDict([String: Any])
}

// MARK: - HTTPStatusCode
enum HTTPStatusCode: Int {
    // 1xx Informational
    case `continue` = 100
    case switchingProtocols = 101
    case processing = 102

    // 2xx Success
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritative = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206

    // 3xx Redirection
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case temporaryRedirect = 307
    case permanentRedirect = 308

    // 4xx Client Error
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case conflict = 409
    case gone = 410
    case unsupportedMediaType = 415
    case tooManyRequests = 429

    // 5xx Server Error
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504

    var isInformational: Bool {
        (100 ..< 200).contains(rawValue)
    }

    var isSuccess: Bool {
        (200 ..< 300).contains(rawValue)
    }

    var isRedirect: Bool {
        (300 ..< 400).contains(rawValue)
    }

    var isClientError: Bool {
        (400 ..< 500).contains(rawValue)
    }

    var isServerError: Bool {
        (500 ..< 600).contains(rawValue)
    }
}
