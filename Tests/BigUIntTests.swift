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
        XCTAssertEqual(String(b5, radix: 16), "1827364554637281")

        let b6 = BigUInt(UInt32(0x12345678))
        XCTAssertEqual(String(b6, radix: 16), "12345678")

        let b7 = BigUInt(IntMax(0x1827364554637281))
        XCTAssertEqual(String(b7, radix: 16), "1827364554637281")

        let b8 = BigUInt(Int16(0x1234))
        XCTAssertEqual(String(b8, radix: 16), "1234")

        let b9: BigUInt = 0x1827364554637281
        XCTAssertEqual(String(b9, radix: 16), "1827364554637281")
    }

    func testInitFromLiterals() {
        XCTAssertEqual(42 as BigUInt, BigUInt(42))
        XCTAssertEqual("42" as BigUInt, BigUInt(42))

        // I have no idea how to exercise these in the wild
        XCTAssertEqual(BigUInt(unicodeScalarLiteral: UnicodeScalar(52)), BigUInt(4))
        XCTAssertEqual(BigUInt(extendedGraphemeClusterLiteral: "4"), BigUInt(4))
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

    func testConversionToString() {
        let sample = BigUInt("123456789ABCDEFEDCBA98765432123456789ABCDEF", radix: 16)!
        // Radix = 10
        XCTAssertEqual(String(BigUInt()), "0")
        XCTAssertEqual(String(BigUInt(1)), "1")
        XCTAssertEqual(String(BigUInt(100)), "100")
        XCTAssertEqual(String(BigUInt(12345)), "12345")
        XCTAssertEqual(String(BigUInt(123456789)), "123456789")
        XCTAssertEqual(String(sample), "425693205796080237694414176550132631862392541400559")

        // Radix = 16
        XCTAssertEqual(String(BigUInt(0x1001), radix: 16), "1001")
        XCTAssertEqual(String(BigUInt(0x0102030405060708), radix: 16), "102030405060708")
        XCTAssertEqual(String(sample, radix: 16), "123456789abcdefedcba98765432123456789abcdef")
        XCTAssertEqual(String(sample, radix: 16, uppercase: true), "123456789ABCDEFEDCBA98765432123456789ABCDEF")

        // Radix = 2
        XCTAssertEqual(String(BigUInt(12), radix: 2), "1100")
        XCTAssertEqual(String(BigUInt(123), radix: 2), "1111011")
        XCTAssertEqual(String(BigUInt(1234), radix: 2), "10011010010")
        XCTAssertEqual(String(sample, radix: 2), "1001000110100010101100111100010011010101111001101111011111110110111001011101010011000011101100101010000110010000100100011010001010110011110001001101010111100110111101111")

        // Radix = 31
        XCTAssertEqual(String(BigUInt(30), radix: 31), "u")
        XCTAssertEqual(String(BigUInt(31), radix: 31), "10")
        XCTAssertEqual(String(BigUInt("10000000000000000", radix: 16)!, radix: 31), "nd075ib45k86g")
        XCTAssertEqual(String(BigUInt("2908B5129F59DB6A41", radix: 16)!, radix: 31), "100000000000000")
        XCTAssertEqual(String(sample, radix: 31), "ptf96helfaqi7ogc3jbonmccrhmnc2b61s")
    }

    func testConversionFromString() {
        let sample = "123456789ABCDEFEDCBA98765432123456789ABCDEF"

        XCTAssertEqual(BigUInt("1")!, 1)
        XCTAssertEqual(BigUInt("123456789ABCDEF", radix: 16)!, 0x123456789ABCDEF)
        XCTAssertEqual(BigUInt("1000000000000000000000"), BigUInt("3635C9ADC5DEA00000", radix: 16))
        XCTAssertEqual(BigUInt("10000000000000000", radix: 16), BigUInt("18446744073709551616"))
        XCTAssertEqual(BigUInt(sample, radix: 16)!, BigUInt("425693205796080237694414176550132631862392541400559")!)

        XCTAssertNil(BigUInt("Not a number"))
        XCTAssertNil(BigUInt("X"))
        XCTAssertNil(BigUInt("12349A"))
        XCTAssertNil(BigUInt("000000000000000000000000A000"))
        XCTAssertNil(BigUInt("00A0000000000000000000000000"))
        XCTAssertNil(BigUInt("00 0000000000000000000000000"))
        XCTAssertNil(BigUInt("\u{4e00}\u{4e03}")) // Chinese numerals "1", "7"

        XCTAssertEqual(BigUInt("u", radix: 31)!, 30)
        XCTAssertEqual(BigUInt("10", radix: 31)!, 31)
        XCTAssertEqual(BigUInt("100000000000000", radix: 31)!, BigUInt("2908B5129F59DB6A41", radix: 16)!)
        XCTAssertEqual(BigUInt("nd075ib45k86g", radix: 31)!, BigUInt("10000000000000000", radix: 16)!)
        XCTAssertEqual(BigUInt("ptf96helfaqi7ogc3jbonmccrhmnc2b61s", radix: 31)!, BigUInt(sample, radix: 16)!)
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
        XCTAssertEqual(bll, BigUInt([0, 1]))
        let blh = bl.high
        XCTAssertEqual(blh, BigUInt([2, 0]))
        let bhl = bh.low
        XCTAssertEqual(bhl, BigUInt([3, 4]))
        let bhh = bh.high
        XCTAssertEqual(bhh, BigUInt([5, 0]))

        let blhl = bll.low
        XCTAssertEqual(blhl, BigUInt([0]))
        let blhh = bll.high
        XCTAssertEqual(blhh, BigUInt([1]))
        let bhhl = bhl.low
        XCTAssertEqual(bhhl, BigUInt([3]))
        let bhhh = bhl.high
        XCTAssertEqual(bhhh, BigUInt([4]))
    }

    func testComparison() {
        XCTAssertEqual(BigUInt([1, 2, 3]), BigUInt([1, 2, 3]))
        XCTAssertNotEqual(BigUInt([1, 2]), BigUInt([1, 2, 3]))
        XCTAssertNotEqual(BigUInt([1, 2, 3]), BigUInt([1, 3, 3]))
        XCTAssertEqual(BigUInt([1, 2, 3, 4, 5, 6]).low.high, BigUInt([3]))

        XCTAssertTrue(BigUInt([1, 2]) < BigUInt([1, 2, 3]))
        XCTAssertTrue(BigUInt([1, 2, 2]) < BigUInt([1, 2, 3]))
        XCTAssertFalse(BigUInt([1, 2, 3]) < BigUInt([1, 2, 3]))
        XCTAssertTrue(BigUInt([3, 3]) < BigUInt([1, 2, 3, 4, 5, 6])[2..<4])
        XCTAssertTrue(BigUInt([1, 2, 3, 4, 5, 6]).low.high < BigUInt([3, 5]))
    }

    func testIsZero() {
        let b = BigUInt([0, 0, 0, 1])

        XCTAssertFalse(b.isZero)
        XCTAssertTrue(b.low.isZero)
        XCTAssertTrue(b.high.low.isZero)
        XCTAssertFalse(b.high.high.isZero)
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

    func testBitwise() {
        let a = BigUInt("1234567890ABCDEF13579BDF2468ACE", radix: 16)!
        let b = BigUInt("ECA8642FDB97531FEDCBA0987654321", radix: 16)!

        //                                    a = 01234567890ABCDEF13579BDF2468ACE
        //                                    b = 0ECA8642FDB97531FEDCBA0987654321
        XCTAssertEqual(String(~a,    radix: 16), "fedcba9876f543210eca86420db97531")
        XCTAssertEqual(String(a | b, radix: 16),  "febc767fdbbfdfffffdfbbdf767cbef")
        XCTAssertEqual(String(a & b, radix: 16),    "2044289083410f014380982440200")
        XCTAssertEqual(String(a ^ b, radix: 16),  "fe9c32574b3c9ef0fe9c3b47523c9ef")

        let ffff = BigUInt(Array(count: 30, repeatedValue: Digit.max))
        XCTAssertEqual(~ffff, 0)
        XCTAssertEqual(a | ffff, ffff)
        XCTAssertEqual(a | 0, a)
        XCTAssertEqual(a & a, a)
        XCTAssertEqual(a & 0, 0)
        XCTAssertEqual(a & ffff, a)
        XCTAssertEqual(~(a | b), (~a & ~b))
        XCTAssertEqual(~(a & b), (~a | ~b))
        XCTAssertEqual(a ^ a, 0)
        XCTAssertEqual((a ^ b) ^ b, a)
        XCTAssertEqual((a ^ b) ^ a, b)

        var z = a * b
        z |= a
        z &= b
        z ^= ffff
        XCTAssertEqual(z, (((a * b) | a) & b) ^ ffff)

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

        b += 2
        XCTAssertEqual(b, BigUInt([5, 3, 2]))

        b = BigUInt([Digit.max, 2, Digit.max])
        b.increment()
        XCTAssertEqual(b, BigUInt([0, 3, Digit.max]))

        XCTAssertEqual(BigUInt([Digit.max - 5, Digit.max, 4, Digit.max]).addDigit(6), BigUInt([0, 0, 5, Digit.max]))

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
        var a1 = BigUInt([1, 2, 3, 4])
        XCTAssertFalse(a1.subtractDigitInPlaceWithOverflow(3, shift: 1))
        XCTAssertEqual(a1, BigUInt([1, Digit.max, 2, 4]))

        let (diff, overflow) = BigUInt([1, 2, 3, 4]).subtractDigitWithOverflow(2)
        XCTAssertEqual(diff, BigUInt([Digit.max, 1, 3, 4]))
        XCTAssertFalse(overflow)

        var a2 = BigUInt([1, 2, 3, 4])
        XCTAssertTrue(a2.subtractDigitInPlaceWithOverflow(5, shift: 3))
        XCTAssertEqual(a2, BigUInt([1, 2, 3, Digit.max]))

        var a3 = BigUInt([1, 2, 3, 4])
        a3.subtractDigitInPlace(4, shift: 3)
        XCTAssertEqual(a3, BigUInt([1, 2, 3]))

        var a4 = BigUInt([1, 2, 3, 4])
        a4.decrement()
        XCTAssertEqual(a4, BigUInt([0, 2, 3, 4]))
        a4.decrement()
        XCTAssertEqual(a4, BigUInt([Digit.max, 1, 3, 4]))

        XCTAssertEqual(BigUInt([1, 2, 3, 4]).subtractDigit(5), BigUInt([Digit.max - 3, 1, 3, 4]))

        XCTAssertEqual(BigUInt(0) - BigUInt(0), BigUInt(0))

        var b = BigUInt([1, 2, 3, 4])
        XCTAssertFalse(b.subtractInPlaceWithOverflow(BigUInt([0, 1, 1, 1])))
        XCTAssertEqual(Array(b), [1, 1, 2, 3])

        let b1 = BigUInt([1, 1, 2, 3]).subtractWithOverflow(BigUInt([1, 1, 3, 3]))
        XCTAssertEqual(b1.0, BigUInt([0, 0, Digit.max, Digit.max]))
        XCTAssertTrue(b1.1)

        let b2 = BigUInt([0, 0, 1]) - BigUInt([1])
        XCTAssertEqual(Array(b2), [Digit.max, Digit.max])

        var b3 = BigUInt([1, 0, 0, 1])
        b3 -= 2
        XCTAssertEqual(Array(b3), [Digit.max, Digit.max, Digit.max])
    }

    func testMultiplyByDigit() {
        XCTAssertEqual(BigUInt([1, 2, 3, 4]).multiplyByDigit(0), BigUInt(0))
        XCTAssertEqual(BigUInt([1, 2, 3, 4]).multiplyByDigit(2), BigUInt([2, 4, 6, 8]))

        let full = Digit.max

        let b = BigUInt([full, 0, full, 0, full]).multiplyByDigit(2)
        XCTAssertEqual(b, BigUInt([full - 1, 1, full - 1, 1, full - 1, 1]))

        let c = BigUInt([full, full, full]).multiplyByDigit(2)
        XCTAssertEqual(c, BigUInt([full - 1, full, full, 1]))

        let d = BigUInt([full, full, full]).multiplyByDigit(full)
        XCTAssertEqual(d, BigUInt([1, full, full, full - 1]))

        let e = BigUInt("11111111111111111111111111111111", radix: 16)!.multiplyByDigit(15)
        XCTAssertEqual(e, BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", radix: 16)!)

        let f = BigUInt("11111111111111111111111111111112", radix: 16)!.multiplyByDigit(15)
        XCTAssertEqual(f, BigUInt("10000000000000000000000000000000E", radix: 16)!)
    }

    func testMultiplication() {
        func test() {
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

            var b = BigUInt("2637AB28", radix: 16)!
            b *= BigUInt("164B", radix: 16)!
            XCTAssertEqual(b, BigUInt("353FB0494B8", radix: 16))
            
            XCTAssertEqual(BigUInt("16B60", radix: 16)! * BigUInt("33E28", radix: 16)!, BigUInt("49A5A0700", radix: 16)!)
        }

        test()
        // Disable brute force multiplication.
        let limit = BigUInt.directMultiplicationLimit
        BigUInt.directMultiplicationLimit = 0
        defer { BigUInt.directMultiplicationLimit = limit }

        test()
    }

    func testLeftShifts() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        var a = sample

        a <<= 0
        XCTAssertEqual(a, sample)

        a = sample
        a <<= 1
        XCTAssertEqual(a, 2 * sample)

        a = sample
        a <<= Digit.width
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a[0], 0)
        XCTAssertEqual(a[1...sample.count + 1], sample)

        a = sample
        a <<= 100 * Digit.width
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a[0..<100], 0)
        XCTAssertEqual(a[100...sample.count + 100], sample)

        a = sample
        a <<= 100 * Digit.width + 2
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a[0..<100], 0)
        XCTAssertEqual(a[100...sample.count + 100], sample << 2)

        a = sample
        a <<= Digit.width - 1
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a, BigUInt([0] + Array(sample)) / 2)

        XCTAssertEqual(sample << 4, 16 * sample)
        XCTAssertEqual(sample << (2 * Digit.width), BigUInt([0, 0] + Array(sample)))
        XCTAssertEqual(sample << (2 * Digit.width + 2), BigUInt([0, 0] + Array(4 * sample)))
    }

    func testRightShifts() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        var a = sample

        a >>= 0
        XCTAssertEqual(a, sample)

        a = sample
        a >>= 1
        XCTAssertEqual(a, sample / 2)

        a = sample
        a >>= Digit.width
        XCTAssertEqual(a, sample[1..<sample.count])

        a = sample
        a >>= Digit.width + 2
        XCTAssertEqual(a, sample[1..<sample.count] / 4)

        a = sample
        a >>= sample.count * Digit.width
        XCTAssertEqual(a, 0)

        XCTAssertEqual(sample >> 0, sample)
        XCTAssertEqual(sample >> 3, sample / 8)
        XCTAssertEqual(sample >> Digit.width, sample[1..<sample.count])
        XCTAssertEqual(sample >> (Digit.width + 3), sample[1..<sample.count] / 8)
        XCTAssertEqual(sample >> (100 * Digit.width), 0)
    }

    func testWidth() {
        XCTAssertEqual(BigUInt(0).width, 0)
        XCTAssertEqual(BigUInt(1).width, 1)
        XCTAssertEqual(BigUInt(Digit.max).width, Digit.width)
        XCTAssertEqual(BigUInt([Digit.max, 1]).width, Digit.width + 1)
        XCTAssertEqual(BigUInt([2, 12]).width, Digit.width + 4)
        XCTAssertEqual(BigUInt([1, Digit.max]).width, 2 * Digit.width)

        XCTAssertEqual(BigUInt(0).numberOfLeadingZeroes, 0)
        XCTAssertEqual(BigUInt(1).numberOfLeadingZeroes, Digit.width - 1)
        XCTAssertEqual(BigUInt(Digit.max).numberOfLeadingZeroes, 0)
        XCTAssertEqual(BigUInt([Digit.max, 1]).numberOfLeadingZeroes, Digit.width - 1)
        XCTAssertEqual(BigUInt([14, Digit.max]).numberOfLeadingZeroes, 0)

    }

    func testDivision() {
        func test(a: [Digit], _ b: [Digit], file: String = __FILE__, line: UInt = __LINE__) {
            let x = BigUInt(a)
            let y = BigUInt(b)
            let (div, mod) = BigUInt.divmod(x, y)
            XCTAssertLessThan(mod, y, "x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            XCTAssertEqual(div * y + mod, x, "x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
        }
        // These cases exercise all code paths in the division when Digit is UInt8 or UInt64.
        test([], [1])
        test([1], [1])
        test([1], [2])
        test([2], [1])
        test([], [0, 1])
        test([1], [0, 1])
        test([0, 1], [0, 1])
        test([0, 0, 1], [0, 1])
        test([0, 0, 1], [1, 1])
        test([0, 0, 1], [3, 1])
        test([0, 0, 1], [75, 1])
        test([0, 0, 0, 1], [0, 1])
        test([2, 4, 6, 8], [1, 2])
        test([2, 3, 4, 5], [4, 5])
        test([Digit.max, Digit.max - 1, Digit.max], [Digit.max, Digit.max])
        test([0, Digit.max, Digit.max - 1], [Digit.max, Digit.max])
        test([0, 0, 0, 0, 0, Digit.max / 2 + 1, Digit.max / 2], [1, 0, 0, Digit.max / 2 + 1])

        XCTAssertEqual(BigUInt(328) / BigUInt(21), BigUInt(15))
        XCTAssertEqual(BigUInt(328) % BigUInt(21), BigUInt(13))

        var a = BigUInt(328)
        a /= 21
        XCTAssertEqual(a, 15)
        a %= 7
        XCTAssertEqual(a, 1)

        #if false
            for y0 in Array(1 ... Int(Digit.max)).reverse() {
                for y1 in Array(0 ... Int(Digit.max)).reverse() {
                    for x0 in Array(1 ... Int(Digit.max)).reverse() {
                        for x1 in Array(0 ... Int(Digit.max)).reverse() {
                            for x2 in Array(0 ... Int(Digit.max)).reverse() {
                                test(
                                    [Digit(x2), Digit(x1), Digit(x0)],
                                    [Digit(y1), Digit(y0)])
                            }
                        }
                    }
                }
            }
        #endif
    }

    func testFactorial() {
        let power = 10
        var forward = BigUInt(1)
        for i in 1 ..< (1 << power) {
            forward *= BigUInt(i)
        }
        print("\(1 << power - 1)! = \(forward) [\(forward.count)]")
        var backward = BigUInt(1)
        for i in (1 ..< (1 << power)).reverse() {
            backward *= BigUInt(i)
        }

        func balancedFactorial(level level: Int, offset: Int) -> BigUInt {
            if level == 0 {
                return BigUInt(offset == 0 ? 1 : offset)
            }
            let a = balancedFactorial(level: level - 1, offset: 2 * offset)
            let b = balancedFactorial(level: level - 1, offset: 2 * offset + 1)
            return a * b
        }
        let balanced = balancedFactorial(level: power, offset: 0)

        XCTAssertEqual(backward, forward)
        XCTAssertEqual(balanced, forward)

        var remaining = balanced
        for i in 1 ..< (1 << power) {
            let (div, mod) = BigUInt.divmod(remaining, BigUInt(i))
            XCTAssertEqual(mod, 0)
            remaining = div
        }
        XCTAssertEqual(remaining, 1)
    }

    func testSqrt() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        XCTAssertEqual(sqrt(BigUInt(256)), 16)

        func checkSqrt(value: BigUInt, file: String = __FILE__, line: UInt = __LINE__) {
            let root = sqrt(sample)
            XCTAssertLessThanOrEqual(root * root, sample, file: file, line: line)
            XCTAssertGreaterThan((root + 1) * (root + 1), sample, file: file, line: line)
        }
        checkSqrt(sample)
        checkSqrt(sample * sample)
        checkSqrt(sample * sample - 1)
        checkSqrt(sample * sample + 1)
    }
}
