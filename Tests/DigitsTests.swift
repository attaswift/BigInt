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

    func testMultiplyDigits() {
        var high, low: Digit

        (high, low) = Digit.fullMultiply(2, 3)
        XCTAssertEqual(low, 6)
        XCTAssertEqual(high, 0)

        (high, low) = Digit.fullMultiply(Digit.max, 2)
        XCTAssertEqual(low, Digit.max - 1)
        XCTAssertEqual(high, 1)

        (high, low) = Digit.fullMultiply(1 << Digit.halfShift, 2)
        XCTAssertEqual(low, 1 << (Digit.halfShift + 1))
        XCTAssertEqual(high, 0)

        (high, low) = Digit.fullMultiply(2, 1 << Digit.halfShift)
        XCTAssertEqual(low, 1 << (Digit.halfShift + 1))
        XCTAssertEqual(high, 0)

        (high, low) = Digit.fullMultiply(Digit.max, Digit.max)
        XCTAssertEqual(low, 1)
        XCTAssertEqual(high, Digit.max - 1)

        let half = Digit(Digit.max.low)
        (high, low) = Digit.fullMultiply(half << Digit.halfShift, half)
        XCTAssertEqual(low, 1 << Digit.halfShift)
        XCTAssertEqual(high, half - 1)

        (high, low) = Digit.fullMultiply(half, half << Digit.halfShift)
        XCTAssertEqual(low, 1 << Digit.halfShift)
        XCTAssertEqual(high, half - 1)

    }
}
