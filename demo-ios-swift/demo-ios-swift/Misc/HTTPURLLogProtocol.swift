//
//  HTTPURLLogProtocol.swift
//  demo-ios-swift
//
//  Copyright © 2026 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import Foundation

// MARK: - HTTPURLLogProtocol
/**
 This protocol logs all requests/responses that are passed through URLSession
 */
final class HTTPURLLogProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        // Avoid infinite loop by setting flag 
        if URLProtocol.property(forKey: "_logged_", in: request) != nil {
            return false
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        var request = ((self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest) ?? NSMutableURLRequest()
        URLProtocol.setProperty(true, forKey: "_logged_", in: request)

        let entryId = UUID()
        let requestBody = captureBody(from: &request)
        let logEntry = HTTPURLLogEntry(id: entryId, date: Date(), request: request as URLRequest, requestData: requestBody, response: nil, responseData: nil, error: nil)
        HTTPURLLogStore.update(logEntry)

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let response = response as? HTTPURLResponse {
                let updateLogEntry = HTTPURLLogEntry(id: entryId, date: Date(), request: request as URLRequest, requestData: requestBody, response: response, responseData: data, error: error)
                HTTPURLLogStore.update(updateLogEntry)
            }

            // Pass-through the URL system

            if let response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data {
                self.client?.urlProtocol(self, didLoad: data)
            }

            if let error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }

        task.resume()
    }

    override func stopLoading() {}
}

// MARK: - HTTPURLLogEntry
struct HTTPURLLogEntry: Identifiable, CustomDebugStringConvertible {
    let id: UUID
    let date: Date
    let request: URLRequest
    let requestData: Data?
    let response: HTTPURLResponse?
    let responseData: Data?
    let error: Error?

    var debugDescription: String {
        return "[HTTPURLLogEntry]\n"
            + "🔹 RequestId: \(id.uuidString)\n"
            + _requestDebugDescription
            + "\n\n"
            + _responseDebugDescription
    }

    var requestDebugDescription: String {
        return "[HTTPURLLogEntry]\n"
            + "🔹 RequestId: \(id.uuidString)\n"
            + _requestDebugDescription
    }

    var responseDebugDescription: String {
        return "[HTTPURLLogEntry]\n"
            + "🔹 RequestId: \(id.uuidString)\n"
            + _responseDebugDescription
    }

    private var _requestDebugDescription: String {
        guard let requestHTTPMethod = request.httpMethod, let requestURL = request.url else {
            return "⛔️ URLRequest is not complete"
        }

        var output = [String]()

        output.append("⬆️ \(requestHTTPMethod) \(requestURL)")

        if let httpHeaders = request.allHTTPHeaderFields?.sorted(by: { $0.key < $1.key }) {
            output.append("🔸 Headers:")
            output.append(contentsOf: httpHeaders.map({ "\t\($0): \($1)" }))
        }

        if let requestData {
            output.append("🔹 Body:")
            output.append("\t\(String(decoding: requestData, as: UTF8.self))")
        }

        return output.joined(separator: "\n")
    }

    private var _responseDebugDescription: String {
        guard let response, let responseURL = response.url?.absoluteString else {
            return "⛔️ URLResponse is not complete"
        }

        var output = [String]()

        output.append("⬇️ \(response.statusCode) \(responseURL)")

        if response.allHeaderFields.isEmpty == false, let httpHeaders = response.allHeaderFields as? [String: String] {
            output.append("🔸 Headers:")
            output.append(contentsOf: httpHeaders.sorted(by: { $0.key < $1.key }).map({ "\t\($0): \($1)" }))
        }

        if let responseData {
            output.append("🔹 Body:")
            output.append("\t\(String(decoding: responseData, as: UTF8.self))")
        }

        return output.joined(separator: "\n")
    }
}

// MARK: - HTTPURLLogStore
enum HTTPURLLogStore {
    private static let queue = DispatchQueue(label: "network.log.store", attributes: .concurrent)
    private static let kMaxCapacity: UInt = 20
    private static var entries: [HTTPURLLogEntry] = []

    fileprivate static func update(_ entry: HTTPURLLogEntry) {
        queue.async(flags: .barrier) {
            self.entries.append(entry)
            if self.entries.count > self.kMaxCapacity {
                self.entries.removeFirst()
            }
        }

        NotificationCenter.default.post(name: .HTTPURLLogUpdated, object: nil, userInfo: ["data": entry])
    }

    static func all() -> [HTTPURLLogEntry] {
        queue.sync { entries }
    }

    static func filter(_ predicate: (HTTPURLLogEntry) -> Bool) -> [HTTPURLLogEntry] {
        queue.sync { entries.filter(predicate) }
    }
}

extension Notification.Name {
    static let HTTPURLLogUpdated = Notification.Name("HTTPURLLogUpdated")
}

// MARK: - Misc
private func captureBody(from request: inout NSMutableURLRequest) -> Data? {
    if let body = request.httpBody {
        return body
    }

    if let stream = request.httpBodyStream {
        let data = drainStream(stream)
        request.httpBodyStream = InputStream(data: data)
        return data
    }

    return nil
}

private func drainStream(_ stream: InputStream) -> Data {
    stream.open()
    defer { stream.close() }

    var data = Data()
    let bufferSize = 8 * 1024
    var buffer = [UInt8](repeating: 0, count: bufferSize)

    while true {
        let bytesRead = stream.read(&buffer, maxLength: bufferSize)

        if bytesRead > 0 {
            data.append(buffer, count: bytesRead)
        } else if bytesRead == 0 {
            // End of stream
            break
        } else {
            // Error occurred
            break
        }
    }

    return data
}
