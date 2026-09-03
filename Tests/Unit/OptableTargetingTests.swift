//
//  OptableTargetingTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

class OptableTargetingTests: XCTestCase {
    /// Targeting data in the shape returned by the edge targeting endpoint:
    /// `ortb2.user.eids[].uids[].ext.optable.ref` points into `refs`, where the signature lives.
    private func targetingData(source: String = "id5-sync.com", signature: Any = "id5-sig-abc123") -> [String: Any] {
        return [
            "ortb2": [
                "user": [
                    "eids": [
                        [
                            "source": source,
                            "uids": [
                                ["id": "ID5*uid", "ext": ["optable": ["ref": "0"]]],
                            ],
                        ],
                    ],
                ],
            ],
            "refs": ["0": ["signature": signature]],
        ]
    }

    func test_id5Signature_extracted_from_valid_targeting_data() {
        let targeting = OptableTargeting(optableTargeting: targetingData())
        XCTAssertEqual(targeting.id5Signature, "id5-sig-abc123")
    }

    func test_id5Signature_source_matching_is_case_insensitive() {
        let targeting = OptableTargeting(optableTargeting: targetingData(source: "ID5-Sync.com"))
        XCTAssertEqual(targeting.id5Signature, "id5-sig-abc123")
    }

    func test_id5Signature_nil_when_source_is_not_id5() {
        let targeting = OptableTargeting(optableTargeting: targetingData(source: "liveramp.com"))
        XCTAssertNil(targeting.id5Signature)
    }

    func test_id5Signature_nil_when_signature_empty_or_whitespace() {
        XCTAssertNil(OptableTargeting(optableTargeting: targetingData(signature: "")).id5Signature)
        XCTAssertNil(OptableTargeting(optableTargeting: targetingData(signature: "   ")).id5Signature)
    }

    func test_id5Signature_nil_when_signature_is_not_a_string() {
        let targeting = OptableTargeting(optableTargeting: targetingData(signature: 123))
        XCTAssertNil(targeting.id5Signature)
    }

    func test_id5Signature_nil_when_targeting_data_empty() {
        XCTAssertNil(OptableTargeting(optableTargeting: [:]).id5Signature)
    }

    func test_id5Signature_nil_when_refs_missing() {
        var data = targetingData()
        data["refs"] = nil
        XCTAssertNil(OptableTargeting(optableTargeting: data).id5Signature)
    }

    func test_id5Signature_nil_when_ref_not_found_in_refs() {
        var data = targetingData()
        data["refs"] = ["other-ref": ["signature": "id5-sig-abc123"]]
        XCTAssertNil(OptableTargeting(optableTargeting: data).id5Signature)
    }

    func test_id5Signature_nil_when_uid_has_no_optable_ref() {
        var data = targetingData()
        data["ortb2"] = ["user": ["eids": [["source": "id5-sync.com", "uids": [["id": "ID5*uid"]]]]]]
        XCTAssertNil(OptableTargeting(optableTargeting: data).id5Signature)
    }

    func test_id5Signature_found_among_multiple_eids() {
        var data = targetingData()
        var eids = ((data["ortb2"] as! [String: Any])["user"] as! [String: Any])["eids"] as! [[String: Any]]
        eids.insert(["source": "liveramp.com", "uids": [["id": "ramp-uid"]]], at: 0)
        data["ortb2"] = ["user": ["eids": eids]]
        XCTAssertEqual(OptableTargeting(optableTargeting: data).id5Signature, "id5-sig-abc123")
    }
}
