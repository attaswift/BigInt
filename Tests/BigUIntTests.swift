//
//  BigUIntTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

class BigUIntTests: XCTestCase {
    func testInit() {
        let b1 = BigUInt(digits: [12, 34, 56], level: 1, offset: 2)
        XCTAssertEqual(b1._digits, [12, 34, 56])
        XCTAssertEqual(b1._level, 1)
        XCTAssertEqual(b1._offset, 2)

        let b2 = BigUInt()
        XCTAssertEqual(b2._digits, [])
        XCTAssertEqual(b2._level, 0)
        XCTAssertEqual(b2._offset, 0)

        let b3 = BigUInt([1, 2])
        XCTAssertEqual(b3._digits, [1, 2])
        XCTAssertEqual(b3._level, 2)
        XCTAssertEqual(b3._offset, 0)

        let b3p = BigUInt([1, 2, 3, 4, 5])
        XCTAssertEqual(b3p._digits, [1, 2, 3, 4, 5])
        XCTAssertEqual(b3p._level, 4)
        XCTAssertEqual(b3p._offset, 0)

        let b4 = BigUInt(UIntMax(0x1827364554637281))
        XCTAssertEqual(String(b4), "1827364554637281")
        XCTAssertEqual(b4._offset, 0)

        let b5 = BigUInt(UInt32(0x12345678))
        XCTAssertEqual(String(b5), "12345678")
        XCTAssertEqual(b5._offset, 0)

        let b6: BigUInt = 0x1827364554637281
        XCTAssertEqual(String(b6), "1827364554637281")
        XCTAssertEqual(b6._offset, 0)
    }

    func testDigits() {
        let b0 = BigUInt()
        XCTAssertEqual(b0._digits, [])

        let b1 = BigUInt([1])
        XCTAssertEqual(b1._digits, [1])

        let b2 = BigUInt([0, 1])
        XCTAssertEqual(b2._digits, [0, 1])

        let b3 = BigUInt([0, 1, 0])
        XCTAssertEqual(b3._digits, [0, 1])

        let b4 = BigUInt([1, 0, 0, 0])
        XCTAssertEqual(b4._digits, [1])

        let b5 = BigUInt([0, 0, 0, 0, 0, 0])
        XCTAssertEqual(b5._digits, [])
    }

    func testSubscriptingGetter() {
        let b = BigUInt([1, 2])
        XCTAssertEqual(b[0], 1)
        XCTAssertEqual(b[1], 2)
        XCTAssertEqual(b[2], 0)
        XCTAssertEqual(b[3], 0)
        XCTAssertEqual(b[10000], 0)
    }

    func testSubscriptingSetter() {
        var d = BigUInt()

        XCTAssertEqual(d.count, 0)
        XCTAssertEqual(d[0], 0)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 0)

        d[10] = 0
        XCTAssertEqual(d.count, 0)
        XCTAssertEqual(d[0], 0)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 0)

        d[0] = 42
        XCTAssertEqual(d.count, 1)
        XCTAssertEqual(d[0], 42)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 0)

        d[10] = 23
        XCTAssertEqual(d.count, 16)
        XCTAssertEqual(d[0], 42)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 23)

        d[0] = 0
        XCTAssertEqual(d.count, 16)
        XCTAssertEqual(d[0], 0)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 23)

        d[10] = 0
        XCTAssertEqual(d.count, 0)
        XCTAssertEqual(d[0], 0)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 0)
        
        XCTAssertEqual(d, BigUInt())
    }

    func testExtend() {
        var d = BigUInt()
        d.extend(3)
        XCTAssertEqual(d.count, 4)
        XCTAssertEqual(d[0], 0)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[2], 0)
        XCTAssertEqual(d[3], 0)

        d.extend(1)
        XCTAssertEqual(d.count, 4)

        d.shrink()
        XCTAssertEqual(d.count, 0)
    }
    

    func testConversionToString() {
        XCTAssertEqual(String(BigUInt()), "0")
        XCTAssertEqual(String(BigUInt(1)), "1")
        XCTAssertEqual(String(BigUInt(0x1001)), "1001")
        XCTAssertEqual(String(BigUInt(0x0102030405060708)), "102030405060708")
    }

    func testLowHigh() {
        let a = BigUInt([0, 1, 2, 3])
        XCTAssertEqual(a.low, BigUInt([0, 1]))
        XCTAssertEqual(a.high, BigUInt([2, 3]))
        XCTAssertEqual(a.low.low, BigUInt([0]))
        XCTAssertEqual(a.low.high, BigUInt([1]))
        XCTAssertEqual(a.high.low, BigUInt([2]))
        XCTAssertEqual(a.high.high, BigUInt([3]))

        let b = BigUInt([0, 1, 2, 3, 4, 5])

        let bl = b.low
        XCTAssertEqual(bl, BigUInt([0, 1, 2, 3]))
        let bh = b.high
        XCTAssertEqual(bh, BigUInt([4, 5]))

        let bll = bl.low
        XCTAssertEqual(bll, BigUInt([0, 1]))
        let blh = bl.high
        XCTAssertEqual(blh, BigUInt([2, 3]))
        let bhl = bh.low
        XCTAssertEqual(bhl, BigUInt([4, 5]))
        let bhh = bh.high
        XCTAssertEqual(bhh, BigUInt())

        let blll = bll.low
        XCTAssertEqual(blll, BigUInt([0]))
        let bllh = bll.high
        XCTAssertEqual(bllh, BigUInt([1]))
        let blhl = blh.low
        XCTAssertEqual(blhl, BigUInt([2]))
        let blhh = blh.high
        XCTAssertEqual(blhh, BigUInt([3]))
        let bhll = bhl.low
        XCTAssertEqual(bhll, BigUInt([4]))
        let bhlh = bhl.high
        XCTAssertEqual(bhlh, BigUInt([5]))
    }

    func testComparison() {
        XCTAssertEqual(BigUInt([1, 2, 3]), BigUInt([1, 2, 3]))
        XCTAssertNotEqual(BigUInt([1, 2]), BigUInt([1, 2, 3]))
        XCTAssertEqual(BigUInt([1, 2, 3, 4, 5, 6]).low.high, BigUInt([3, 4]))

        XCTAssertTrue(BigUInt([1, 2]) < BigUInt([1, 2, 3]))
        XCTAssertTrue(BigUInt([1, 2, 2]) < BigUInt([1, 2, 3]))
        XCTAssertFalse(BigUInt([1, 2, 3]) < BigUInt([1, 2, 3]))
        XCTAssertTrue(BigUInt([3, 3]) < BigUInt([1, 2, 3, 4, 5, 6]).low.high)
        XCTAssertTrue(BigUInt([1, 2, 3, 4, 5, 6]).low.high < BigUInt([3, 5]))
    }

    func testIsZero() {
        let b = BigUInt([0, 0, 0, 1])

        XCTAssertFalse(b.isZero)
        XCTAssertTrue(b.low.isZero)
        XCTAssertTrue(b.low.low.isZero)
        XCTAssertTrue(b.low.high.isZero)
        XCTAssertTrue(b.high.low.isZero)
        XCTAssertFalse(b.high.high.isZero)
    }

    func testSlice() {
        let value = BigUInt([0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20])
        let slice = value[3..<6]

        XCTAssertEqual(slice.count, 3)
        XCTAssertEqual(slice.startIndex, 0)
        XCTAssertEqual(slice.endIndex, 3)

        XCTAssertTrue(slice.elementsEqual([6, 8, 10]))
        XCTAssertEqual(slice[0], 6)
        XCTAssertEqual(slice[1], 8)
        XCTAssertEqual(slice[2], 10)
    }

    func testNegation() {
        let b = BigUInt("0123456789ABCDEFFEDCBA9876543210")!
        XCTAssertEqual(~b, BigUInt("FEDCBA98765432100123456789ABCDEF")!)
    }

    func testAddition() {
        XCTAssertEqual(BigUInt(0) + BigUInt(0), BigUInt(0))
        XCTAssertEqual(BigUInt(0) + BigUInt(Digit.max), BigUInt(Digit.max))
        XCTAssertEqual(BigUInt(Digit.max) + BigUInt(1), BigUInt([0, 1]))

        var b = BigUInt()
        XCTAssertEqual(b, 0)

        b.add(BigUInt(Digit.max))
        XCTAssertEqual(b, BigUInt(Digit.max))

        b.add(1)
        XCTAssertEqual(b, BigUInt([0, 1]))

        b.add(BigUInt([3, 4]))
        XCTAssertEqual(b, BigUInt([3, 5]))

        b.add(BigUInt([0, Digit.max]))
        XCTAssertEqual(b, BigUInt([3, 4, 1]))

        b.add(BigUInt([0, Digit.max]))
        XCTAssertEqual(b, BigUInt([3, 3, 2]))
    }

    func testShiftedAddition() {
        var b = BigUInt()
        b.add(1, shift: 1)
        XCTAssertEqual(b, BigUInt([0, 1]))

        b.add(2, shift: 3)
        XCTAssertEqual(b, BigUInt([0, 1, 0, 2]))

        b.add(BigUInt(Digit.max), shift: 1)
        XCTAssertEqual(b, BigUInt([0, 0, 1, 2]))
    }

    func testSubtraction() {
        XCTAssertEqual(BigUInt(0) - BigUInt(0), BigUInt(0))

        var b = BigUInt([1, 2, 3, 4])
        XCTAssertFalse(b.subtractWithOverflow(BigUInt([0, 1, 1, 1])))
        XCTAssertEqual(Array(b), [1, 1, 2, 3])

        XCTAssertTrue(b.subtractWithOverflow(BigUInt([1, 1, 3, 3])))
        XCTAssertEqual(Array(b), [0, 0, Digit.max, Digit.max])

        let b2 = BigUInt([0, 0, 1]) - BigUInt([1])
        XCTAssertEqual(Array(b2), [Digit.max, Digit.max])
    }

    func testMultiplyByDigit() {
        XCTAssertEqual(BigUInt([1, 2, 3, 4]).scalarMultiply(2), BigUInt([2, 4, 6, 8]))

        let full = Digit.max

        let b = BigUInt([full, 0, full, 0, full]).scalarMultiply(2)
        XCTAssertEqual(b, BigUInt([full - 1, 1, full - 1, 1, full - 1, 1]))

        let c = BigUInt([full, full, full]).scalarMultiply(2)
        XCTAssertEqual(c, BigUInt([full - 1, full, full, 1]))

        let d = BigUInt([full, full, full]).scalarMultiply(full)
        XCTAssertEqual(d, BigUInt([1, full, full, full - 1]))

        let e = BigUInt(Array(count: 16, repeatedValue: Digit(17))).scalarMultiply(15)
        XCTAssertEqual(e, BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")!)

        let f = BigUInt([18] + Array(count: 15, repeatedValue: Digit(17))).scalarMultiply(15)
        XCTAssertEqual(f, BigUInt("10000000000000000000000000000000E")!)
    }

    func testMultiply() {
        XCTAssertEqual(
            BigUInt([1, 2, 3, 4]) * BigUInt(),
            BigUInt())
        XCTAssertEqual(
            BigUInt() * BigUInt([1, 2, 3, 4]),
            BigUInt())
        XCTAssertEqual(
            BigUInt([1, 2, 3, 4]) * BigUInt([2]),
            BigUInt([2, 4, 6, 8]))
        XCTAssertEqual(
            BigUInt([2]) * BigUInt([1, 2, 3, 4]),
            BigUInt([2, 4, 6, 8]))
        XCTAssertEqual(
            BigUInt([1, 2, 3, 4]) * BigUInt([0, 1]),
            BigUInt([0, 1, 2, 3, 4]))
        XCTAssertEqual(
            BigUInt([0, 1]) * BigUInt([1, 2, 3, 4]),
            BigUInt([0, 1, 2, 3, 4]))
        // 999 * 99 = 98901
        XCTAssertEqual(
            BigUInt([Digit.max, Digit.max, Digit.max]) * BigUInt([Digit.max, Digit.max]),
            BigUInt([1, 0, Digit.max, Digit.max - 1, Digit.max]))
        XCTAssertEqual(
            BigUInt([1, 2]) * BigUInt([2, 1]),
            BigUInt([2, 5, 2]))
    }
}
