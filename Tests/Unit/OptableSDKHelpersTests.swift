//
//  OptableSDKHelpersTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

class OptableSDKHelpersTests: XCTestCase {
    // MARK: Identifiers Enrichment
    // MARK: GAM Keywords
    func test_generateGAMTargetingKeywords_nilOrEmpty() {
        XCTAssertNil(OptableSDK.generateGAMTargetingKeywords(from: nil))
        XCTAssertNil(OptableSDK.generateGAMTargetingKeywords(from: [:]))
        XCTAssertNil(OptableSDK.generateGAMTargetingKeywords(from: ["user": [:]]))
    }

    func test_generateGAMTargetingKeywords_valid() {
        let targetingData: NSDictionary = [
            "audience": [
                [
                    "keyspace": "ks1",
                    "ids": [["id": "a1"], ["id": "a2"]],
                ],
                [
                    "keyspace": "ks2",
                    "ids": [["id": "b1"]],
                ],
            ],
        ]

        let result = OptableSDK.generateGAMTargetingKeywords(from: targetingData)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["ks1"] as? String, "a1,a2")
        XCTAssertEqual(result?["ks2"] as? String, "b1")
    }

    // MARK: ORTB2 Config
    func test_generateORTB2Config_nilOrEmpty() {
        XCTAssertNil(OptableSDK.generateORTB2Config(from: nil))
        XCTAssertNil(OptableSDK.generateORTB2Config(from: [:]))
        XCTAssertNil(OptableSDK.generateORTB2Config(from: ["user": [:]]))
    }

    func test_generateORTB2Config_valid() throws {
        let ortb2: NSDictionary = [
            "user": [
                "data": [
                    [
                        "id": "optable.co",
                        "segment": [["id": "seg-1"], ["id": "seg-2"]],
                    ],
                ],
            ],
        ]
        let targetingData: NSDictionary = [
            "ortb2": ortb2,
        ]

        guard let result = OptableSDK.generateORTB2Config(from: targetingData) else {
            return XCTFail("Expected non-nil ORTB2 config string")
        }

        // Validate by decoding back to JSON and comparing dictionaries
        let data = try XCTUnwrap(result.data(using: .utf8))
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary)
        XCTAssertEqual(json, ortb2)
    }

    // MARK: OptableTargeting
    func test_generateOptableTargeting_nilData_returnsEmpty() throws {
        let targeting = try OptableSDK.generateOptableTargeting(from: nil)
        XCTAssert(targeting.targetingData.isEmpty)
        XCTAssertNil(targeting.gamTargetingKeywords)
        XCTAssertNil(targeting.ortb2)
    }

    func test_generateOptableTargeting_parsesAudienceAndORTB2() throws {
        let jsonDict: NSDictionary = [
            "audience": [
                [
                    "provider": "optable.co",
                    "keyspace": "ks1",
                    "ids": [["id": "a1"], ["id": "a2"]],
                ],
                [
                    "provider": "optable.co",
                    "keyspace": "ks2",
                    "ids": [["id": "b1"]],
                ],
            ],
            "ortb2": [
                "user": [
                    "data": [
                        [
                            "id": "optable.co",
                            "segment": [["id": "seg-1"]],
                        ],
                    ],
                ],
            ],
        ]

        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let targeting = try OptableSDK.generateOptableTargeting(from: data)

        // targetingData should reflect input JSON
        XCTAssertEqual(targeting.targetingData["audience"] as? NSArray, jsonDict["audience"] as? NSArray)

        // gamTargetingKeywords should be derived from "audience"
        XCTAssertEqual(targeting.gamTargetingKeywords?["ks1"] as? String, "a1,a2")
        XCTAssertEqual(targeting.gamTargetingKeywords?["ks2"] as? String, "b1")

        // ortb2 should be a JSON string equivalent to provided dict
        let ortb2String = try XCTUnwrap(targeting.ortb2)
        let ortb2Data = try XCTUnwrap(ortb2String.data(using: .utf8))
        let ortb2Decoded = try XCTUnwrap(try JSONSerialization.jsonObject(with: ortb2Data, options: []) as? NSDictionary)
        XCTAssertEqual(ortb2Decoded, jsonDict["ortb2"] as? NSDictionary)
    }

    // MARK: EdgeAPIErrorDescription
    func test_generateEdgeAPIErrorDescription_includesStatusAndJSON() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com"))
        let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 418, httpVersion: nil, headerFields: nil))
        let json: NSDictionary = ["error": "I'm a teapot", "code": 418]
        let data = try? JSONSerialization.data(withJSONObject: json, options: [])

        let message = OptableSDK.generateEdgeAPIErrorDescription(with: data, response: response)
        XCTAssertTrue(message.contains("HTTP response.statusCode: 418"))
        XCTAssertTrue(message.contains("error"))
        XCTAssertTrue(message.contains("teapot"))
    }

    func test_generateEdgeAPIErrorDescription_noData() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com"))
        let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil))

        let message = OptableSDK.generateEdgeAPIErrorDescription(with: nil, response: response)
        XCTAssertTrue(message.contains("HTTP response.statusCode: 500"))
        XCTAssertFalse(message.contains("data:"))
    }

    // MARK: Version
    func test_version_notUnknown() {
        // Should resolve to something like ios-<marketing>-<build>
        XCTAssertNotEqual(OptableSDK.version, "ios-unknown")
        XCTAssertTrue(OptableSDK.version.hasPrefix("ios-"))
    }
}
