//
//  Networking.swift
//  OptableSDK
//
//  Created by user on 15.12.2025.
//  Copyright © 2025 Optable Technologies, Inc. All rights reserved.
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
enum HTTPStatusCode {
    // 1xx Informational
    case `continue` // 100
    case switchingProtocols // 101
    case processing // 102

    // 2xx Success
    case ok // 200
    case created // 201
    case accepted // 202
    case nonAuthoritative // 203
    case noContent // 204
    case resetContent // 205
    case partialContent // 206

    // 3xx Redirection
    case multipleChoices // 300
    case movedPermanently // 301
    case found // 302
    case seeOther // 303
    case notModified // 304
    case temporaryRedirect // 307
    case permanentRedirect // 308

    // 4xx Client Error
    case badRequest // 400
    case unauthorized // 401
    case paymentRequired // 402
    case forbidden // 403
    case notFound // 404
    case methodNotAllowed // 405
    case notAcceptable // 406
    case conflict // 409
    case gone // 410
    case unsupportedMediaType // 415
    case tooManyRequests // 429

    // 5xx Server Error
    case internalServerError // 500
    case notImplemented // 501
    case badGateway // 502
    case serviceUnavailable // 503
    case gatewayTimeout // 504

    // Categories
    case informational // 100 ..< 200
    case successful // 200 ..< 300
    case redirect // 300 ..< 400
    case clientError // 400 ..< 500
    case serverError // 500 ..< 600

    // swiftlint:disable:next cyclomatic_complexity
    init(statusCode: Int) {
        self = switch statusCode {
        // 1xx
        case 100: .continue
        case 101: .switchingProtocols
        case 102: .processing
        // 2xx
        case 200: .ok
        case 201: .created
        case 202: .accepted
        case 203: .nonAuthoritative
        case 204: .noContent
        case 205: .resetContent
        case 206: .partialContent
        // 3xx
        case 300: .multipleChoices
        case 301: .movedPermanently
        case 302: .found
        case 303: .seeOther
        case 304: .notModified
        case 307: .temporaryRedirect
        case 308: .permanentRedirect
        // 4xx
        case 400: .badRequest
        case 401: .unauthorized
        case 402: .paymentRequired
        case 403: .forbidden
        case 404: .notFound
        case 405: .methodNotAllowed
        case 406: .notAcceptable
        case 409: .conflict
        case 410: .gone
        case 415: .unsupportedMediaType
        case 429: .tooManyRequests
        // 5xx
        case 500: .internalServerError
        case 501: .notImplemented
        case 502: .badGateway
        case 503: .serviceUnavailable
        case 504: .gatewayTimeout
        // Ranges
        case 100 ..< 200: .informational
        case 200 ..< 300: .successful
        case 300 ..< 400: .redirect
        case 400 ..< 500: .clientError
        case 500 ..< 600: .serverError
        default:
            .serverError
        }
    }

    var isSuccess: Bool {
        if case .successful = self { return true }
        if case .ok = self { return true }
        return false
    }
}
