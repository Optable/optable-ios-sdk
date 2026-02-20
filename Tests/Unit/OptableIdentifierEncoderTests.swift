//
//  OptableIdentifierEncoderTests.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

@testable import OptableSDK
import XCTest

class OptableIdentifierEncoderTests: XCTestCase {
    typealias SUT = OptableIdentifierEncoder

    func test_email() {
        let prefix = OptableIdentifier.emailAddress("").prefix

        var expected = "e:a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"
        XCTAssertEqual(expected, SUT.email(prefix, "123"))
        XCTAssertEqual(expected, SUT.email(prefix, " 123"))
        XCTAssertEqual(expected, SUT.email(prefix, "123 "))
        XCTAssertEqual(expected, SUT.email(prefix, " 123 "))

        expected = "e:9e9bff5609b2e4b721e682ce7a0759d4f042819bc15a698bcb99db7897555239"
        XCTAssertEqual(expected, SUT.email(prefix, "tEsT@  FooBarBaz.CoM"))
        XCTAssertEqual(expected, SUT.email(prefix, "     test@foobarbaz.com"))
        XCTAssertEqual(expected, SUT.email(prefix, "TEST@FOOBARBAZ.COM     "))
        XCTAssertEqual(expected, SUT.email(prefix, "TeSt@ f O O b A R b A Z.cOm"))
    }

    func test_phoneNumber() {
        let prefix = OptableIdentifier.phoneNumber("").prefix

        let expected = "p:ebad3b64ae96005048fca1af2f15e5251ad3844d00fb80252711de9b651c8e46"
        XCTAssertEqual(expected, SUT.phoneNumber(prefix, "+33 555 456789"))
        XCTAssertEqual(expected, SUT.phoneNumber(prefix, "+33555456789"))
        XCTAssertEqual(expected, SUT.phoneNumber(prefix, "+3 3 5 5 5456789"))
        XCTAssertEqual(expected, SUT.phoneNumber(prefix, "   +33555456789   "))
    }

    func test_postalCode() {
        let prefix = OptableIdentifier.postalCode("").prefix

        XCTAssertEqual("z:m5v 3l9", SUT.postalCode(prefix, " M5V 3L9"))
        XCTAssertEqual("z:t 2 p 5 h 1", SUT.postalCode(prefix, "T 2 P 5 H 1"))
        XCTAssertEqual("z:90210", SUT.postalCode(prefix, "90210"))
        XCTAssertEqual("z:10001", SUT.postalCode(prefix, "10001"))
        XCTAssertEqual("z:sw1a 1aa", SUT.postalCode(prefix, "SW1A 1AA"))
        XCTAssertEqual("z:eh1 1bb", SUT.postalCode(prefix, "EH1 1BB"))
    }

    func test_id5() {
        let prefix = OptableIdentifier.id5("").prefix

        let expected = "id5:ID5*UDWnp3JOtWV0ky-bHvEeU4xOVHXCmYeg24YigF8iAymUHplfYSElM3fy79h8p-Fg"
        XCTAssertEqual(expected, SUT.id5(prefix, "  ID5*UDWnp3JOtWV0ky-bHvEeU4xOVHXCmYeg24YigF8iAymUHplfYSElM3fy79h8p-Fg   "))
        XCTAssertEqual(expected, SUT.id5(prefix, "ID5*UDWnp 3JOtWV0ky-bHvE eU4xOVHXCmYeg2 4YigF8iAymU HplfYSEl M3fy79h8p-Fg"))
    }

    func test_utiq() {
        let prefix = OptableIdentifier.utiq("").prefix

        let expected = "utiq:496f5db5-681f-4392-acd5-0d4f6e2f6b88"
        XCTAssertEqual(expected, SUT.utiq(prefix, "496f5DB5-681F-4392-aCD5-0d4f6e2f6b88"))
        XCTAssertEqual(expected, SUT.utiq(prefix, " 496f5db5 -681f -4392- acd5-0d4f6e2f6b88 "))
    }

    func test_ipv4() {
        let prefix = OptableIdentifier.ipv4Address("").prefix

        let expected = "i4:8.8.8.8"
        XCTAssertEqual(expected, SUT.ipv4(prefix, "8.8.8.8"))
        XCTAssertEqual(expected, SUT.ipv4(prefix, "  8. 8. 8. 8  "))
    }

    func test_ipv6() {
        let prefix = OptableIdentifier.ipv6Address("").prefix

        let expected = "i6:2001:0db8:85a3:0000:0000:8a2e:0370:7334"
        XCTAssertEqual(expected, SUT.ipv6(prefix, "2001:0DB8:85A3:0000:0000:8a2e:0370:7334"))
        XCTAssertEqual(expected, SUT.ipv6(prefix, "2001:0db8:85a3:0000:0000:8a2e:0370:7334"))
    }

    func test_idfa() {
        let prefix = OptableIdentifier.appleIDFA("").prefix

        let expected = "a:496f5db5-681f-4392-acd5-0d4f6e2f6b88"
        XCTAssertEqual(expected, SUT.idfa(prefix, "496f5DB5-681F-4392-acd5-0d4f6e2f6b88"))
        XCTAssertEqual(expected, SUT.idfa(prefix, "496f5db5- 681f- 4392- acd5- 0d4f6e2f6b88"))
    }

    func test_gaid() {
        let prefix = OptableIdentifier.googleGAID("").prefix

        let expected = "g:64873d9f-d5af-4770-8bcb-167a220eb17d"
        XCTAssertEqual(expected, SUT.gaid(prefix, "64873d9f-d5AF-4770-8bcb-167a220eb17d"))
        XCTAssertEqual(expected, SUT.gaid(prefix, " 64873d9f- d5af-4770- 8bcb-167a220eb17d "))
    }

    func test_rida() {
        let prefix = OptableIdentifier.rokuRIDA("").prefix

        let expected = "r:0b179df0-6cd5-49f1-be21-425d002e0d22"
        XCTAssertEqual(expected, SUT.rida(prefix, "0b179df0-6CD5-49f1-be21-425d002e0d22"))
        XCTAssertEqual(expected, SUT.rida(prefix, "  0b179df0 -6cd5- 49f1-be21-425d002e0d22 "))
    }

    func test_tifa() {
        let prefix = OptableIdentifier.samsungTIFA("").prefix

        let expected = "s:e0ef86a8-6ebf-4c9d-9127-e69407fe748d"
        XCTAssertEqual(expected, SUT.tifa(prefix, "e0ef86a8-6EBf-4c9d-9127-e69407fe748d"))
        XCTAssertEqual(expected, SUT.tifa(prefix, "  e0ef86a8- 6ebf-4c9 d-9127-e69407fe748d "))
    }

    func test_afai() {
        let prefix = OptableIdentifier.amazonFireAFAI("").prefix

        let expected = "f:6e853799-ef31-4a30-8706-9742be254d38"
        XCTAssertEqual(expected, SUT.afai(prefix, "6E853799-EF31-4a30-8706-9742be254d38"))
        XCTAssertEqual(expected, SUT.afai(prefix, " 6 e853799- ef31-4a30-8706-9742be254d38 "))
    }

    func test_netid() {
        let prefix = OptableIdentifier.netID("").prefix

        let expected = "n:_YV2v2Uhx3vqeH47Rrhzgr-4c3VNsxis4M1WY9qn--QTbVapax5VM2HJykoGAyWcwS5lKQ"
        XCTAssertEqual(expected, SUT.netid(prefix, " _YV2v2Uhx3vqe H47Rrhzgr-4c3VNs xis4M1WY9qn--QTbVapax5VM2HJykoGAyWcwS5lKQ "))
        XCTAssertEqual(expected, SUT.netid(prefix, "_YV2v2Uhx3vqeH47Rrhzgr-4c3VNsxis4M1WY9qn--QTbVapax5VM2HJykoGAyWcwS5lKQ"))
    }

    func test_custom() {
        let prefix = OptableIdentifier.custom(nil, "").prefix

        let expected = "c:FooBarBAZ-01234#98765.!!!"
        XCTAssertEqual(expected, SUT.custom(prefix, "FooBarBAZ-01234#98765.!!!"))
        XCTAssertEqual(expected, SUT.custom(prefix, " FooBarBAZ-01234#98765.!!!"))
        XCTAssertEqual(expected, SUT.custom(prefix, "FooBarBAZ-01234#98765.!!!  "))
        XCTAssertEqual(expected, SUT.custom(prefix, "  FooBarBAZ-01234#98765.!!!  "))

        // Case sensitive
        let unexpected = "c:FooBarBAZ-01234#98765.!!!"
        XCTAssertNotEqual(unexpected, SUT.custom(prefix, "foobarBAZ-01234#98765.!!!"))
    }

    // MARK: Legacy
    func test_eidFromURL_isCorrect() {
        let url = "http://some.domain.com/some/path?some=query&something=else&oeid=a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3&foo=bar&baz"
        let expected = "e:a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"

        XCTAssertEqual(expected, SUT.eidFromURL(url))
    }

    func test_eidFromURL_returnsEmptyWhenArgEmpty() {
        let url = ""
        let expected = ""

        XCTAssertEqual(expected, SUT.eidFromURL(url))
    }

    func test_eidFromURL_returnsEmptyWhenOeidAbsentFromQuerystring() {
        let url = "http://some.domain.com/some/path?some=query&something=else"
        let expected = ""

        XCTAssertEqual(expected, SUT.eidFromURL(url))
    }

    func test_eidFromURL_returnsEmptyWhenQuerystringAbsent() {
        let url = "http://some.domain.com/some/path"
        let expected = ""

        XCTAssertEqual(expected, SUT.eidFromURL(url))
    }

    func test_eidFromURL_expectsSHA256() {
        let url = "http://some.domain.com/some/path?some=query&something=else&oeid=AAAAAAAa665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3&foo=bar&baz"
        let expected = ""

        XCTAssertEqual(expected, SUT.eidFromURL(url))
    }

    func test_eidFromURL_ignoresCase() {
        let url = "http://some.domain.com/some/path?some=query&something=else&oEId=A665A45920422F9D417E4867EFDC4FB8A04A1F3FFF1FA07E998E86f7f7A27AE3&foo=bar&baz"
        let expected = "e:a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"

        XCTAssertEqual(expected, SUT.eidFromURL(url))
    }
}
