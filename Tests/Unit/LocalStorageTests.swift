//
//  LocalStorageTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

// MARK: - LocalStorageTests
class LocalStorageTests: XCTestCase {
    /*
     NOTE:
     Swift Dictionary<String, Any> does not conform `Equatable` because of `Any`.
     But Swift effortlessly bridges Dictionary<String, Any> to NSDictionary and vice versa.
     Thus casting to NSDictionary is used to perform comparsion and equality operations.
     */
    
    private let optableConfig = OptableConfig(tenant: "tenant", originSlug: "slug")
    private lazy var localStorage = LocalStorage(optableConfig)
    
    func testOptableTargetingStoringFull() {
        let optableTargetingFull = OptableTargeting(
            optableTargeting: kOptableTargeting as! [String : Any],
            gamTargetingKeywords: kGamTargetingKeywords as? [String : Any],
            ortb2: kORTB2
        )
        
        localStorage.setTargeting(optableTargetingFull)
        
        let readTargeting = localStorage.getTargeting()
        XCTAssert(readTargeting != nil)
        XCTAssert(readTargeting!.targetingData as NSDictionary == kOptableTargeting)
        XCTAssert(readTargeting!.gamTargetingKeywords as? NSDictionary == kGamTargetingKeywords)
        XCTAssert(readTargeting!.ortb2 == kORTB2)
    }
    
    func testOptableTargetingStoringPartial1() {
        let optableTargetingFull = OptableTargeting(
            optableTargeting: kOptableTargeting as! [String : Any],
            gamTargetingKeywords: nil,
            ortb2: kORTB2
        )
        
        localStorage.setTargeting(optableTargetingFull)
        
        let readTargeting = localStorage.getTargeting()
        XCTAssert(readTargeting != nil)
        XCTAssert(readTargeting!.targetingData as NSDictionary == kOptableTargeting)
        XCTAssert(readTargeting!.gamTargetingKeywords as? NSDictionary == nil)
        XCTAssert(readTargeting!.ortb2 == kORTB2)
    }
    
    func testOptableTargetingStoringPartial2() {
        let optableTargetingFull = OptableTargeting(
            optableTargeting: kOptableTargeting as! [String : Any],
            gamTargetingKeywords: kGamTargetingKeywords as? [String : Any],
            ortb2: nil
        )
        
        localStorage.setTargeting(optableTargetingFull)
        
        let readTargeting = localStorage.getTargeting()
        XCTAssert(readTargeting != nil)
        XCTAssert(readTargeting!.targetingData as NSDictionary == kOptableTargeting)
        XCTAssert(readTargeting!.gamTargetingKeywords as? NSDictionary == kGamTargetingKeywords)
        XCTAssert(readTargeting!.ortb2 == nil)
    }
    
    func testClearOptableTargeting() {
        let optableTargetingFull = OptableTargeting(
            optableTargeting: kOptableTargeting as! [String : Any],
            gamTargetingKeywords: kGamTargetingKeywords as? [String : Any],
            ortb2: kORTB2
        )
        
        localStorage.setTargeting(optableTargetingFull)
        
        localStorage.clearTargeting()
        
        XCTAssert(localStorage.getTargeting() == nil)
    }
}

private let kOptableTargeting: NSDictionary = [
    "user": [
    ],
    "resolved_ids": [
        "v:1BVKqIAArvNzSSGBHylNzD",
    ],
    "audience": [
        [
            "provider": "optable.co",
            "keyspace": "optable-test",
            "rtb_segtax": 5001,
            "ids": [
                [
                    "id": "082793f9",
                ],
            ],
        ],
    ],
    "ortb2": [
        "user": [
            "data": [
                [
                    "id": "optable.co",
                    "segment": [
                        [
                            "id": "082793f9",
                        ],
                    ],
                ],
            ],
            "eids": [
                [
                    "matcher": "optable.co",
                    "inserter": "optable.co",
                    "uids": [
                        [
                            "id": "c:new-custom.ABC",
                        ],
                        [
                            "id": "e:129c907cd4f2b4d95d76b63ec9661c64cddad5de53415a0116173bc324072968",
                        ],
                        [
                            "id": "e:33de963e0e7a36efd205666b5c8c40958ab0e7921fd004f07f2d51460233c216",
                        ],
                        [
                            "id": "e:7e6ea62ad413e64265919670246b2992f4d15ca38b994c27298b63a588dd8ba8",
                        ],
                        [
                            "id": "e:f660ab912ec121d1b1e928a0bb4bc61b15f5ad44d5efdc4e1c92a25e99b8e44a",
                        ],
                        [
                            "id": "v:04aRMhLIDKLhhib22vZ16o",
                        ],
                        [
                            "id": "v:0b5zRoKB03RnzAZJaneBN4",
                        ],
                        [
                            "id": "v:0xpp3chKzFjUEuzCy2PcJc",
                        ],
                        [
                            "id": "v:17pZOV6BmGyUYifUNpYJsq",
                        ],
                        [
                            "id": "v:1BVKqIAArvNzSSGBHylNzD",
                        ],
                        [
                            "id": "v:2UrRt9jeXPXAxxxsxTbGu9",
                        ],
                        [
                            "id": "v:2lRpxRE23u8sONiRXF5ApS",
                        ],
                        [
                            "id": "v:3VAn89d4ykHHQVQsJwyE7o",
                        ],
                        [
                            "id": "v:43WUDNJQNDJSjLCSX0qwha",
                        ],
                        [
                            "id": "v:4ARkTKp1HZmVkfGm5MqQ7G",
                        ],
                        [
                            "id": "v:4B4qgjdrBYtU9tn0RfjqJY",
                        ],
                        [
                            "id": "v:6sE6iVTAmGEYvnLgBIXkpH",
                        ],
                        [
                            "id": "v:6wZ8XnZ2FuO8EQSxGK3OnS",
                        ],
                        [
                            "id": "v:726sPNyh2p0nUydFXTSW1w",
                        ],
                        [
                            "id": "v:7SMH58RSiiCODwKuEIOBJj",
                        ],
                        [
                            "id": "v:7hqlpHRC3VFithzQViVrxH",
                        ],
                    ],
                    "source": "optable.co",
                    "mm": 3,
                ],
                [
                    "matcher": "optable.co",
                    "inserter": "optable.co",
                    "uids": [
                        [
                            "id": "CIJj1V9rSndLY1QlMkJkajdUeWZrT0RqNGJxSmkxTW5nZ3g0c2U4dnR3bVVwQUZyTjFDOGVXeWlySzFUanclMkZCZ2VZRTExNG1NeG12eXJUWUUlMkJVcHBpJTJGTGRHVFc1bVpIZ3dhc25BNDJ1Q1ROSnFjbVZFJTNE",
                            "atype": 3,
                            "ext": [
                                "stype": "cto_bundle_hem_api",
                            ],
                        ],
                    ],
                    "source": "criteo-hemapi.com",
                    "mm": 3,
                ],
            ],
        ],
    ],
]

private let kGamTargetingKeywords: NSDictionary = [
    "optable-test": "082793f9",
]

private let kORTB2: String = "ortb2_data"
