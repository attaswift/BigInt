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
        XCTAssertEqual(BigInt(IntMax.min).abs - 1, BigInt(IntMax.max).abs)

        let zero = BigInt(0)
        XCTAssertTrue(zero.abs.isZero)
        XCTAssertFalse(zero.negative)

        let minusOne = BigInt(-1)
        XCTAssertEqual(minusOne.abs, 1)
        XCTAssertTrue(minusOne.negative)

        let b: BigInt = 42
        XCTAssertEqual(b.abs, 42)
        XCTAssertFalse(b.negative)

        XCTAssertEqual(BigInt(UIntMax.max).abs, BigUInt(UIntMax.max))
    }

    func testSign() {
        XCTAssertTrue(BigInt(-1).negative)
        XCTAssertFalse(BigInt(0).negative)
        XCTAssertFalse(BigInt(1).negative)
    }

    func testComparable() {
        XCTAssertTrue(BigInt(1) == BigInt(1))
        XCTAssertFalse(BigInt(1) == BigInt(-1))

        XCTAssertTrue(BigInt(1) < BigInt(42))
        XCTAssertFalse(BigInt(1) < -BigInt(42))
        XCTAssertTrue(BigInt(-1) < BigInt(42))
        XCTAssertTrue(BigInt(-42) < BigInt(-1))
    }

    func testHashable() {
        XCTAssertEqual(BigInt(42).hashValue, BigUInt(42).hashValue)
        XCTAssertNotEqual(BigInt(1).hashValue, BigInt(-1).hashValue)
    }

    func compare(a: Int, _ b: Int, r: Int, file: String = __FILE__, line: UInt = __LINE__, @noescape op: (BigInt, BigInt) -> BigInt) {
        XCTAssertEqual(op(BigInt(a), BigInt(b)), BigInt(r), file: file, line: line)
    }

    func testAddition() {
        compare(0, 0, r: 0, op: +)
        compare(1, 2, r: 3, op: +)
        compare(1, -2, r: -1, op: +)
        compare(-1, 2, r: 1, op: +)
        compare(-1, -2, r: -3, op: +)
        compare(2, -1, r: 1, op: +)
    }

    func testNegation() {
        XCTAssertEqual(-BigInt(0), BigInt(0))
        XCTAssertEqual(-BigInt(1), BigInt(-1))
        XCTAssertEqual(-BigInt(-1), BigInt(1))
    }

    func testSubtraction() {
        compare(0, 0, r: 0, op: -)
        compare(2, 1, r: 1, op: -)
        compare(2, -1, r: 3, op: -)
        compare(-2, 1, r: -3, op: -)
        compare(-2, -1, r: -1, op: -)
    }

    func testMultiplication() {
        compare(0, 0, r: 0, op: *)
        compare(0, 1, r: 0, op: *)
        compare(1, 0, r: 0, op: *)
        compare(0, -1, r: 0, op: *)
        compare(-1, 0, r: 0, op: *)
        compare(2, 3, r: 6, op: *)
        compare(2, -3, r: -6, op: *)
        compare(-2, 3, r: -6, op: *)
        compare(-2, -3, r: 6, op: *)
    }

    func testDivision() {
        compare(0, 1, r: 0, op: /)
        compare(0, -1, r: 0, op: /)
        compare(7, 4, r: 1, op: /)
        compare(7, -4, r: -1, op: /)
        compare(-7, 4, r: -1, op: /)
        compare(-7, -4, r: 1, op: /)
    }

    func testModulo() {
        compare(0, 1, r: 0, op: %)
        compare(0, -1, r: 0, op: %)
        compare(7, 4, r: 3, op: %)
        compare(7, -4, r: 3, op: %)
        compare(-7, 4, r: -3, op: %)
        compare(-7, -4, r:-3, op: %)
    }

    func testAssignmentOperators() {
        var a = BigInt(1)
        a += 13
        XCTAssertEqual(a, 14)

        a -= 7
        XCTAssertEqual(a, 7)

        a *= 3
        XCTAssertEqual(a, 21)

        a /= 2
        XCTAssertEqual(a, 10)

        a %= 7
        XCTAssertEqual(a, 3)
    }
}
