//
//  BigIntTests.swift
//  BigIntTests
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

class BigIntTests: XCTestCase {
    func testInit() {
        XCTAssertTrue(BigInt(IntMax.min).negative)
//        XCTAssertEqual(BigInt(IntMax.min).abs - 1, BigInt(IntMax.max).abs)

    }
    func testSign() {
        XCTAssertTrue(BigInt(-1).negative)
        XCTAssertFalse(BigInt(0).negative)
        XCTAssertFalse(BigInt(1).negative)
    }
    func testAddition() {
        XCTAssertEqual(BigInt(0) + BigInt(0), BigInt(0))
        XCTAssertEqual(BigInt(1) + BigInt(2), BigInt(3))
        XCTAssertEqual(BigInt(1) + BigInt(-2), BigInt(-1))
        XCTAssertEqual(BigInt(-1) + BigInt(2), BigInt(1))
        XCTAssertEqual(BigInt(-2) + BigInt(1), BigInt(-1))
        XCTAssertEqual(BigInt(-2) + BigInt(-1), BigInt(-3))
    }
}
