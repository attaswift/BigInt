//
//  BigIntTests.swift
//  BigIntTests
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import XCTest
@testable import BigInt

class BigIntTests: XCTestCase {
    typealias Word = BigInt.Word

    func testInit() {
        XCTAssertEqual(BigInt(Int64.min).sign, .minus)
        XCTAssertEqual(BigInt(Int64.min).magnitude - 1, BigInt(Int64.max).magnitude)

        let zero = BigInt(0)
        XCTAssertTrue(zero.magnitude.isZero)
        XCTAssertEqual(zero.sign, .plus)

        let minusOne = BigInt(-1)
        XCTAssertEqual(minusOne.magnitude, 1)
        XCTAssertEqual(minusOne.sign, .minus)

        let b: BigInt = 42
        XCTAssertEqual(b.magnitude, 42)
        XCTAssertEqual(b.sign, .plus)

        XCTAssertEqual(BigInt(UInt64.max).magnitude, BigUInt(UInt64.max))

        let b2: BigInt = "+300"
        XCTAssertEqual(b2.magnitude, 300)
        XCTAssertEqual(b2.sign, .plus)

        let b3: BigInt = "-300"
        XCTAssertEqual(b3.magnitude, 300)
        XCTAssertEqual(b3.sign, .minus)

        XCTAssertNil(BigInt("Not a number"))

        XCTAssertEqual(BigInt(unicodeScalarLiteral: UnicodeScalar(52)), BigInt(4))
        XCTAssertEqual(BigInt(extendedGraphemeClusterLiteral: "4"), BigInt(4))
    }

    func testSign() {
        XCTAssertEqual(BigInt(-1).sign, .minus)
        XCTAssertEqual(BigInt(0).sign, .plus)
        XCTAssertEqual(BigInt(1).sign, .plus)
    }

    func testWords() {
        XCTAssertEqual(Array(BigInt(0).words), [])
        XCTAssertEqual(Array(BigInt(1).words), [1])
        XCTAssertEqual(Array(BigInt(-1).words), [Word.max])

        XCTAssertEqual(Array(BigInt(sign: .plus, magnitude: BigUInt(words: [Word.max])).words), [Word.max, 0])
        XCTAssertEqual(Array(BigInt(sign: .minus, magnitude: BigUInt(words: [Word.max])).words), [1, Word.max])

        XCTAssertEqual(Array((BigInt(1) << Word.bitWidth).words), [0, 1])
        XCTAssertEqual(Array((-(BigInt(1) << Word.bitWidth)).words), [0, Word.max])

        XCTAssertEqual(Array((BigInt(42) << Word.bitWidth).words), [0, 42])
        XCTAssertEqual(Array((-(BigInt(42) << Word.bitWidth)).words), [0, Word.max - 41])

        let huge = BigUInt(words: [0, 1, 2, 3, 4])
        XCTAssertEqual(Array(BigInt(sign: .plus, magnitude: huge).words), [0, 1, 2, 3, 4])
        XCTAssertEqual(Array(BigInt(sign: .minus, magnitude: huge).words),
                       [0, Word.max, ~2, ~3, ~4] as [Word])


        XCTAssertEqual(BigInt(1).words[100], 0)
        XCTAssertEqual(BigInt(-1).words[100], Word.max)
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
        XCTAssertEqual(BigInt(1).hashValue, BigInt(1).hashValue)
        XCTAssertNotEqual(BigInt(1).hashValue, BigInt(2).hashValue)
        XCTAssertNotEqual(BigInt(42).hashValue, BigInt(-42).hashValue)
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

    func testRemainder() {
        compare(0, 1, r: 0, op: %)
        compare(0, -1, r: 0, op: %)
        compare(7, 4, r: 3, op: %)
        compare(7, -4, r: 3, op: %)
        compare(-7, 4, r: -3, op: %)
        compare(-7, -4, r:-3, op: %)
    }
  
    func testModulo() {
        XCTAssertEqual(BigInt.modulus(22, 5), 2)
        XCTAssertEqual(BigInt.modulus(-22, 5), 3)
        XCTAssertEqual(BigInt.modulus(22, -5), 2)
        XCTAssertEqual(BigInt.modulus(-22, -5), 3)
    }

    func testStrideableRequirements() {
        XCTAssertEqual(5, BigInt(3).advanced(by: 2))
        XCTAssertEqual(2, BigInt(3).distance(to: 5))
    }

    func testAbsoluteValuableRequirements() {
        XCTAssertEqual(BigInt(5), abs(5 as BigInt))
        XCTAssertEqual(BigInt(0), abs(0 as BigInt))
        XCTAssertEqual(BigInt(5), abs(-5 as BigInt))
    }

    func testIntegerArithmeticRequirements() {
        XCTAssertEqual(3 as Int64, Int64(3 as BigInt))
        XCTAssertEqual(-3 as Int64, Int64(-3 as BigInt))
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
