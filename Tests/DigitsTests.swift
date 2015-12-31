//
//  DigitsTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

class DigitsTests: XCTestCase {

    func testSizeOfDigits() {
        print("sizeof(Digit) is \(sizeof(Digit))")
        #if TinyDigits
            XCTAssertEqual(sizeof(Digit), 1)
        #else
            XCTAssertEqual(sizeof(Digit), 8)
        #endif
    }

    func testFullMultiply() {
        var high, low: Digit

        (high, low) = Digit.fullMultiply(2, 3)
        XCTAssertEqual(low, 6)
        XCTAssertEqual(high, 0)

        (high, low) = Digit.fullMultiply(Digit.max, 2)
        XCTAssertEqual(low, Digit.max - 1)
        XCTAssertEqual(high, 1)

        (high, low) = Digit.fullMultiply(Digit(1).upshifted, 2)
        XCTAssertEqual(low, Digit(1).upshifted * 2)
        XCTAssertEqual(high, 0)

        (high, low) = Digit.fullMultiply(2, Digit(1).upshifted)
        XCTAssertEqual(low, Digit(1).upshifted * 2)
        XCTAssertEqual(high, 0)

        (high, low) = Digit.fullMultiply(Digit.max, Digit.max)
        XCTAssertEqual(low, 1)
        XCTAssertEqual(high, Digit.max - 1)

        let half = Digit.max.low
        (high, low) = Digit.fullMultiply(half.upshifted, half)
        XCTAssertEqual(low, Digit(1).upshifted)
        XCTAssertEqual(high, half - 1)

        (high, low) = Digit.fullMultiply(half, half.upshifted)
        XCTAssertEqual(low, Digit(1).upshifted)
        XCTAssertEqual(high, half - 1)
    }

    func testFullDivide() {
        func testDivision(u: (high: Digit, low: Digit), _ v: Digit) {
            let (div, mod) = Digit.fullDivide(u.high, u.low, v)
            let bu = BigUInt([u.low, u.high])
            let bv = BigUInt(v)
            let bdiv = BigUInt(div)
            let bmod = BigUInt(mod)

            if bmod >= bv {
                XCTFail("For u = \(bu), v = \(bv): u mod v = \(bmod), which is greater than v")
            }
            let p = bdiv * bv + bmod
            XCTAssertEqual(p, bu, "For u = \(bu), v = \(bv), u div v = \(bdiv), u mod v = \(bmod), but div * v + mod = \(p)")
        }

        testDivision((0, 0), 2)
        testDivision((0, 1), 2)
        testDivision((1, 0), 2)
        testDivision((8, 0), 136)
        testDivision((128, 0), 136)
        testDivision((2, 0), 35)
        testDivision((7, 12), 19)

        #if false && TinyDigits
            for v in (0..<Digit.max).map({ $0 + 1 }) {
                for u1 in 0..<v {
                    for u0 in 0...Digit.max.low {
                        testDivision((u1, u0), v)
                    }
                }
            }
        #endif
    }
}
