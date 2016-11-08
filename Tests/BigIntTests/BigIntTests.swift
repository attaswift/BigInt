//
//  BigIntTests.swift
//  BigIntTests
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016 Károly Lőrentey.
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

        let b2: BigInt = "+300"
        XCTAssertEqual(b2.abs, 300)
        XCTAssertFalse(b2.negative)

        let b3: BigInt = "-300"
        XCTAssertEqual(b3.abs, 300)
        XCTAssertTrue(b3.negative)

        XCTAssertNil(BigInt("Not a number"))

        XCTAssertEqual(BigInt(unicodeScalarLiteral: UnicodeScalar(52)), BigInt(4))
        XCTAssertEqual(BigInt(extendedGraphemeClusterLiteral: "4"), BigInt(4))
    }

    func testSign() {
        XCTAssertTrue(BigInt(-1).negative)
        XCTAssertFalse(BigInt(0).negative)
        XCTAssertFalse(BigInt(1).negative)
    }

    func testConversionToString() {
        let b = BigInt(-256)
        XCTAssertEqual(b.description, "-256")
        XCTAssertEqual(String(b, radix: 16, uppercase: true), "-100")
        let pql = b.customPlaygroundQuickLook
        if case PlaygroundQuickLook.text("-256 (9 bits)") = pql {}
        else {
            XCTFail("Unexpected Playground Quick Look: \(pql)")
        }
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

    func compare(_ a: Int, _ b: Int, r: Int, file: StaticString = #file, line: UInt = #line, op: (BigInt, BigInt) -> BigInt) {
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

    func testStrideableRequirements() {
        XCTAssertEqual(5, BigInt(3).advanced(by: 2))
        XCTAssertEqual(2, BigInt(3).distance(to: 5))
    }

    func testAbsoluteValuableRequirements() {
        XCTAssertEqual(BigInt(5), BigInt.abs(5))
        XCTAssertEqual(BigInt(0), BigInt.abs(0))
        XCTAssertEqual(BigInt(5), BigInt.abs(-5))
    }

    func testIntegerArithmeticRequirements() {
        XCTAssertEqual(3 as IntMax, BigInt(3).toIntMax())
        XCTAssertEqual(-3 as IntMax, BigInt(-3).toIntMax())

        XCTAssertEqual(2, BigInt.addWithOverflow(1, 1).0)
        XCTAssertFalse(BigInt.addWithOverflow(1, 1).overflow)

        XCTAssertEqual(-1, BigInt.subtractWithOverflow(2, 3).0)
        XCTAssertFalse(BigInt.subtractWithOverflow(2, 3).overflow)

        XCTAssertEqual(20, BigInt.multiplyWithOverflow(5, 4).0)
        XCTAssertFalse(BigInt.multiplyWithOverflow(5, 4).overflow)

        XCTAssertEqual(3, BigInt.divideWithOverflow(17, 5).0)
        XCTAssertFalse(BigInt.divideWithOverflow(5, 4).overflow)

        XCTAssertEqual(2, BigInt.remainderWithOverflow(17, 5).0)
        XCTAssertFalse(BigInt.remainderWithOverflow(5, 4).overflow)
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
