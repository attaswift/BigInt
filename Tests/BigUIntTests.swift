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
        let b0 = BigUInt()
        XCTAssertEqual(b0._digits, [])
        XCTAssertEqual(b0._start, 0)
        XCTAssertEqual(b0._end, 0)

        let b1 = BigUInt([1, 2])
        XCTAssertEqual(b1._digits, [1, 2])
        XCTAssertEqual(b1._start, 0)
        XCTAssertEqual(b1._end, 2)

        let b2 = BigUInt([1, 2, 3, 0, 0])
        XCTAssertEqual(b2._digits, [1, 2, 3, 0, 0])
        XCTAssertEqual(b2._start, 0)
        XCTAssertEqual(b2._end, 3)

        let b3 = BigUInt(digits: [12, 34, 56], start: 1, end: 2)
        XCTAssertEqual(b3._digits, [12, 34, 56])
        XCTAssertEqual(b3._start, 1)
        XCTAssertEqual(b3._end, 2)

        let b4 = BigUInt(digits: [12, 34, 56], start: 5, end: 10)
        XCTAssertEqual(b4._digits, [12, 34, 56])
        XCTAssertEqual(b4._start, 3)
        XCTAssertEqual(b4._end, 3)

        let b5 = BigUInt(UIntMax(0x1827364554637281))
        XCTAssertEqual(String(b5), "1827364554637281")

        let b6 = BigUInt(UInt32(0x12345678))
        XCTAssertEqual(String(b6), "12345678")

        let b7 = BigUInt(IntMax(0x1827364554637281))
        XCTAssertEqual(String(b7), "1827364554637281")

        let b8 = BigUInt(Int16(0x1234))
        XCTAssertEqual(String(b8), "1234")

        let b9: BigUInt = 0x1827364554637281
        XCTAssertEqual(String(b9), "1827364554637281")

        let b10 = BigUInt("1")!
        XCTAssertEqual(String(b10), "1")

        let b11 = BigUInt("1234567890ABCDEF")!
        XCTAssertEqual(String(b11), "1234567890ABCDEF")

        let b12 = BigUInt("Not a number")
        XCTAssertNil(b12)

        let b13 = BigUInt("X")
        XCTAssertNil(b13)
    }

    func testCollection() {
        let b0 = BigUInt()
        XCTAssertEqual(b0.count, 0)
        XCTAssertEqual(Array(b0), [])

        let b1 = BigUInt([1])
        XCTAssertEqual(b1.count, 1)
        XCTAssertEqual(Array(b1), [1])

        let b2 = BigUInt([0, 1])
        XCTAssertEqual(b2.count, 2)
        XCTAssertEqual(Array(b2), [0, 1])

        let b3 = BigUInt([0, 1, 0])
        XCTAssertEqual(b3.count, 2)
        XCTAssertEqual(Array(b3), [0, 1])

        let b4 = BigUInt([1, 0, 0, 0])
        XCTAssertEqual(b4.count, 1)
        XCTAssertEqual(Array(b4), [1])

        let b5 = BigUInt([0, 0, 0, 0, 0, 0])
        XCTAssertEqual(b5.count, 0)
        XCTAssertEqual(Array(b5), [])
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
        XCTAssertEqual(d.count, 11)
        XCTAssertEqual(d[0], 42)
        XCTAssertEqual(d[1], 0)
        XCTAssertEqual(d[10], 23)

        d[0] = 0
        XCTAssertEqual(d.count, 11)
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
        XCTAssertEqual(bl, BigUInt([0, 1, 2]))
        let bh = b.high
        XCTAssertEqual(bh, BigUInt([3, 4, 5]))

        let bll = bl.low
        XCTAssertEqual(bll, BigUInt([0]))
        let blh = bl.high
        XCTAssertEqual(blh, BigUInt([1, 2]))
        let bhl = bh.low
        XCTAssertEqual(bhl, BigUInt([3]))
        let bhh = bh.high
        XCTAssertEqual(bhh, BigUInt([4, 5]))

        let blhl = blh.low
        XCTAssertEqual(blhl, BigUInt([1]))
        let blhh = blh.high
        XCTAssertEqual(blhh, BigUInt([2]))
        let bhhl = bhh.low
        XCTAssertEqual(bhhl, BigUInt([4]))
        let bhhh = bhh.high
        XCTAssertEqual(bhhh, BigUInt([5]))
    }

    func testComparison() {
        XCTAssertEqual(BigUInt([1, 2, 3]), BigUInt([1, 2, 3]))
        XCTAssertNotEqual(BigUInt([1, 2]), BigUInt([1, 2, 3]))
        XCTAssertNotEqual(BigUInt([1, 2, 3]), BigUInt([1, 3, 3]))
        XCTAssertEqual(BigUInt([1, 2, 3, 4, 5, 6]).low.high, BigUInt([2, 3]))

        XCTAssertTrue(BigUInt([1, 2]) < BigUInt([1, 2, 3]))
        XCTAssertTrue(BigUInt([1, 2, 2]) < BigUInt([1, 2, 3]))
        XCTAssertFalse(BigUInt([1, 2, 3]) < BigUInt([1, 2, 3]))
        XCTAssertTrue(BigUInt([3, 3]) < BigUInt([1, 2, 3, 4, 5, 6])[2..<4])
        XCTAssertTrue(BigUInt([1, 2, 3, 4, 5, 6]).low.high < BigUInt([3, 5]))
    }

    func testHashing() {
        var hashes: [Int] = []
        hashes.append(BigUInt([]).hashValue)
        hashes.append(BigUInt([1]).hashValue)
        hashes.append(BigUInt([2]).hashValue)
        hashes.append(BigUInt([0, 1]).hashValue)
        hashes.append(BigUInt([1, 1]).hashValue)
        hashes.append(BigUInt([1, 2]).hashValue)
        hashes.append(BigUInt([2, 1]).hashValue)
        hashes.append(BigUInt([2, 2]).hashValue)
        hashes.append(BigUInt([1, 2, 3, 4, 5]).hashValue)
        hashes.append(BigUInt([5, 4, 3, 2, 1]).hashValue)
        hashes.append(BigUInt([Digit.max]).hashValue)
        hashes.append(BigUInt([Digit.max, Digit.max]).hashValue)
        hashes.append(BigUInt([Digit.max, Digit.max, Digit.max]).hashValue)
        hashes.append(BigUInt([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).hashValue)
        XCTAssertEqual(hashes.count, Set(hashes).count)
    }

    func testIsZero() {
        let b = BigUInt([0, 0, 0, 1])

        XCTAssertFalse(b.isZero)
        XCTAssertTrue(b.low.isZero)
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

        b.addInPlace(BigUInt(Digit.max))
        XCTAssertEqual(b, BigUInt(Digit.max))

        b.addInPlace(1)
        XCTAssertEqual(b, BigUInt([0, 1]))

        b.addInPlace(BigUInt([3, 4]))
        XCTAssertEqual(b, BigUInt([3, 5]))

        b.addInPlace(BigUInt([0, Digit.max]))
        XCTAssertEqual(b, BigUInt([3, 4, 1]))

        b.addInPlace(BigUInt([0, Digit.max]))
        XCTAssertEqual(b, BigUInt([3, 3, 2]))
    }

    func testShiftedAddition() {
        var b = BigUInt()
        b.addInPlace(1, shift: 1)
        XCTAssertEqual(b, BigUInt([0, 1]))

        b.addInPlace(2, shift: 3)
        XCTAssertEqual(b, BigUInt([0, 1, 0, 2]))

        b.addInPlace(BigUInt(Digit.max), shift: 1)
        XCTAssertEqual(b, BigUInt([0, 0, 1, 2]))
    }

    func testSubtraction() {
        XCTAssertEqual(BigUInt(0) - BigUInt(0), BigUInt(0))

        var b = BigUInt([1, 2, 3, 4])
        XCTAssertFalse(b.subtractInPlaceWithOverflow(BigUInt([0, 1, 1, 1])))
        XCTAssertEqual(Array(b), [1, 1, 2, 3])

        let b1 = BigUInt([1, 1, 2, 3]).subtractWithOverflow(BigUInt([1, 1, 3, 3]))
        XCTAssertEqual(b1.0, BigUInt([0, 0, Digit.max, Digit.max]))
        XCTAssertTrue(b1.1)

        let b2 = BigUInt([0, 0, 1]) - BigUInt([1])
        XCTAssertEqual(Array(b2), [Digit.max, Digit.max])
    }

    func testMultiplyByDigit() {
        XCTAssertEqual(BigUInt([1, 2, 3, 4]).multiplyWithDigit(0), BigUInt(0))
        XCTAssertEqual(BigUInt([1, 2, 3, 4]).multiplyWithDigit(2), BigUInt([2, 4, 6, 8]))

        let full = Digit.max

        let b = BigUInt([full, 0, full, 0, full]).multiplyWithDigit(2)
        XCTAssertEqual(b, BigUInt([full - 1, 1, full - 1, 1, full - 1, 1]))

        let c = BigUInt([full, full, full]).multiplyWithDigit(2)
        XCTAssertEqual(c, BigUInt([full - 1, full, full, 1]))

        let d = BigUInt([full, full, full]).multiplyWithDigit(full)
        XCTAssertEqual(d, BigUInt([1, full, full, full - 1]))

        let e = BigUInt(Array(count: 16, repeatedValue: Digit(17))).multiplyWithDigit(15)
        XCTAssertEqual(e, BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")!)

        let f = BigUInt([18] + Array(count: 15, repeatedValue: Digit(17))).multiplyWithDigit(15)
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
        XCTAssertEqual(
            BigUInt([4, 3, 2, 1]) * BigUInt([1, 2, 3, 4]),
            BigUInt([4, 11, 20, 30, 20, 11, 4]))
        // 999 * 99 = 98901
        XCTAssertEqual(
            BigUInt([Digit.max, Digit.max, Digit.max]) * BigUInt([Digit.max, Digit.max]),
            BigUInt([1, 0, Digit.max, Digit.max - 1, Digit.max]))
        XCTAssertEqual(
            BigUInt([1, 2]) * BigUInt([2, 1]),
            BigUInt([2, 5, 2]))
    }
}
