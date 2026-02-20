//
//  OptableIdentifiersTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

class OptableIdentifiersTests: XCTestCase {
    func test_json_identifier() throws {
        let oids: [OptableIdentifier] = [
            .emailAddress("foo@bar.com"),
            .phoneNumber("+15123465890"),
            .postalCode("M5V 3L9"),
            .ipv4Address("8.8.8.8"),
            .ipv6Address("2001:0db8:85a3:0000:0000:8a2e:0370:7334"),
            .appleIDFA("496f5db5-681f-4392-acd5-0d4f6e2f6b88"),
            .googleGAID("64873d9f-d5af-4770-8bcb-167a220eb17d"),
            .rokuRIDA("0b179df0-6cd5-49f1-be21-425d002e0d22"),
            .samsungTIFA("e0ef86a8-6ebf-4c9d-9127-e69407fe748d"),
            .amazonFireAFAI("6e853799-ef31-4a30-8706-9742be254d38"),
            .netID("_YV2v2Uhx3vqeH47Rrhzgr-4c3VNsxis4M1WY9qn--QTbVapax5VM2HJykoGAyWcwS5lKQ"),
            .id5("ID5*UDWnp3JOtWV0ky-bHvEeU4xOVHXCmYeg24YigF8iAymUHplfYSElM3fy79h8p-Fg"),
            .utiq("496f5db5-681f-4392-acd5-0d4f6e2f6b88"),
            .custom(nil, "d29c551097b9dd0b82423827f65161232efaf7fc"),
            .custom(2, ""),
            .custom(1, "AaaZza.dh012"),
            .custom(1, "another c1"),
        ]
        
        let encodedData = try JSONEncoder().encode(oids)
        let decodedData = try JSONDecoder().decode([String].self, from: encodedData)

        // Test existance
        XCTAssertTrue(decodedData.contains(where: { $0 == "e:0c7e6a405862e402eb76a70f8a26fc732d07c32931e9fae9ab1582911d2e8a3b" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "p:f45562169005d99cdbb6908607fd5b50b66fd835a132a8225cc361d5692a8bd2" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "z:m5v 3l9" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "id5:ID5*UDWnp3JOtWV0ky-bHvEeU4xOVHXCmYeg24YigF8iAymUHplfYSElM3fy79h8p-Fg" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "utiq:496f5db5-681f-4392-acd5-0d4f6e2f6b88" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "i4:8.8.8.8" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "i6:2001:0db8:85a3:0000:0000:8a2e:0370:7334" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "a:496f5db5-681f-4392-acd5-0d4f6e2f6b88" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "g:64873d9f-d5af-4770-8bcb-167a220eb17d" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "r:0b179df0-6cd5-49f1-be21-425d002e0d22" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "s:e0ef86a8-6ebf-4c9d-9127-e69407fe748d" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "f:6e853799-ef31-4a30-8706-9742be254d38" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "n:_YV2v2Uhx3vqeH47Rrhzgr-4c3VNsxis4M1WY9qn--QTbVapax5VM2HJykoGAyWcwS5lKQ" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "c:d29c551097b9dd0b82423827f65161232efaf7fc" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "c2:" }))
        XCTAssertTrue(decodedData.contains(where: { $0 == "c1:AaaZza.dh012" }))

        // Test multiple similar ids existance ( double c1 )
        XCTAssertTrue(decodedData.contains(where: { $0 == "c1:another c1" }))

        // Test order
        let c_Idx = decodedData.firstIndex(of: "c:d29c551097b9dd0b82423827f65161232efaf7fc")!
        let c1_Idx = decodedData.firstIndex(of: "c1:AaaZza.dh012")!
        let c2_Idx = decodedData.firstIndex(of: "c2:")!

        XCTAssert(c_Idx < c2_Idx)
        XCTAssert(c2_Idx < c1_Idx)
    }
}
