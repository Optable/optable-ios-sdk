//
//  OptableSDKTests.swift
//  OptableSDKTests
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import XCTest
@testable import OptableSDK

class OptableSDKTests: XCTestCase {
    var sdk:OptableSDK!

    override func setUpWithError() throws {
        sdk = OptableSDK.init(host: "127.0.0.1", app: "tests", insecure: true)
    }

    override func tearDownWithError() throws {
    }

    func test_eid_isCorrect() throws {
        let expected = "e:a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"
        XCTAssertEqual(expected, sdk.eid("123"))
        XCTAssertEqual(expected, sdk.eid(" 123"))
        XCTAssertEqual(expected, sdk.eid("123 "))
        XCTAssertEqual(expected, sdk.eid(" 123 "))
    }

    func test_eid_ignoresCase() throws {
        let var1 = "tEsT@FooBarBaz.CoM"
        let var2 = "test@foobarbaz.com"
        let var3 = "TEST@FOOBARBAZ.COM"
        let var4 = "TeSt@fOObARbAZ.cOm"
        let eid = sdk.eid(var1)

        XCTAssertEqual(eid, sdk.eid(var2))
        XCTAssertEqual(eid, sdk.eid(var3))
        XCTAssertEqual(eid, sdk.eid(var4))
    }

    func test_aaid_isCorrectAndIgnoresCase() throws {
        let expected = "a:ea7583cd-a667-48bc-b806-42ecb2b48606"

        XCTAssertEqual(expected, sdk.aaid("ea7583cd-a667-48bc-b806-42ecb2b48606"))
        XCTAssertEqual(expected, sdk.aaid("  ea7583cd-a667-48bc-b806-42ecb2b48606"))
        XCTAssertEqual(expected, sdk.aaid("ea7583cd-a667-48bc-b806-42ecb2b48606  "))
        XCTAssertEqual(expected, sdk.aaid("  ea7583cd-a667-48bc-b806-42ecb2b48606  "))
        XCTAssertEqual(expected, sdk.aaid("EA7583CD-A667-48BC-B806-42ECB2B48606"))
    }

    func test_cid_isCorrect() throws {
        let expected = "c:FooBarBAZ-01234#98765.!!!"

        XCTAssertEqual(expected, sdk.cid("FooBarBAZ-01234#98765.!!!"))
        XCTAssertEqual(expected, sdk.cid(" FooBarBAZ-01234#98765.!!!"))
        XCTAssertEqual(expected, sdk.cid("FooBarBAZ-01234#98765.!!!  "))
        XCTAssertEqual(expected, sdk.cid("  FooBarBAZ-01234#98765.!!!  "))
    }

    func test_cid_isCaseSensitive() throws {
        let unexpected = "c:FooBarBAZ-01234#98765.!!!"

        XCTAssertNotEqual(unexpected, sdk.cid("foobarBAZ-01234#98765.!!!"))
    }

    func test_eidFromURL_isCorrect() throws {
        let url = "http://some.domain.com/some/path?some=query&something=else&oeid=a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3&foo=bar&baz"
        let expected = "e:a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"

        XCTAssertEqual(expected, sdk.eidFromURL(url))
    }

    func test_eidFromURL_returnsEmptyWhenArgEmpty() throws {
        let url = ""
        let expected = ""

        XCTAssertEqual(expected, sdk.eidFromURL(url))
    }

    func test_eidFromURL_returnsEmptyWhenOeidAbsentFromQuerystring() throws {
        let url = "http://some.domain.com/some/path?some=query&something=else"
        let expected = ""

        XCTAssertEqual(expected, sdk.eidFromURL(url))
    }

    func test_eidFromURL_returnsEmptyWhenQuerystringAbsent() throws {
        let url = "http://some.domain.com/some/path"
        let expected = ""

        XCTAssertEqual(expected, sdk.eidFromURL(url))
    }

    func test_eidFromURL_expectsSHA256() throws {
        let url = "http://some.domain.com/some/path?some=query&something=else&oeid=AAAAAAAa665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3&foo=bar&baz"
        let expected = ""

        XCTAssertEqual(expected, sdk.eidFromURL(url))
    }

    func test_eidFromURL_ignoresCase() throws {
        let url = "http://some.domain.com/some/path?some=query&something=else&oEId=A665A45920422F9D417E4867EFDC4FB8A04A1F3FFF1FA07E998E86f7f7A27AE3&foo=bar&baz"
        let expected = "e:a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"

        XCTAssertEqual(expected, sdk.eidFromURL(url))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
