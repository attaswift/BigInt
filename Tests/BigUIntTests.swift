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
    typealias Digit = BigUInt.Digit

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
        XCTAssertEqual(~(a & b), (~a | ~b)[0..<(a&b).count])
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
                BigUInt([1, 2, 3, 4]).multiply(BigUInt([2])),
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
        let sample = BigUInt("123456789ABCDEF01234567891631832727633", radix: 16)!

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

        XCTAssertEqual(BigUInt(0).leadingZeroes, 0)
        XCTAssertEqual(BigUInt(1).leadingZeroes, Digit.width - 1)
        XCTAssertEqual(BigUInt(Digit.max).leadingZeroes, 0)
        XCTAssertEqual(BigUInt([Digit.max, 1]).leadingZeroes, Digit.width - 1)
        XCTAssertEqual(BigUInt([14, Digit.max]).leadingZeroes, 0)

        XCTAssertEqual(BigUInt(0).trailingZeroes, 0)
        XCTAssertEqual(BigUInt(1 << Digit(Digit.width - 1)).trailingZeroes, Digit.width - 1)
        XCTAssertEqual(BigUInt(Digit.max).trailingZeroes, 0)
        XCTAssertEqual(BigUInt([0, 1]).trailingZeroes, Digit.width)
        XCTAssertEqual(BigUInt([0, 1 << Digit(Digit.width - 1)]).trailingZeroes, 2 * Digit.width - 1)
    }

    func testDivision() {
        func test(a: [Digit], _ b: [Digit], file: String = __FILE__, line: UInt = __LINE__) {
            let x = BigUInt(a)
            let y = BigUInt(b)
            let (div, mod) = x.divide(y)
            if mod >= y {
                XCTFail("x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            }
            if div * y + mod != x {
                XCTFail("x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            }
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
        test([0, Digit.max - 1, Digit.max / 2 + 1], [Digit.max, Digit.max / 2 + 1])
        test([0, 0, 0x41 << Digit(Digit.width - 8)], [Digit.max, 1 << Digit(Digit.width - 1)])

        XCTAssertEqual(BigUInt(328) / BigUInt(21), BigUInt(15))
        XCTAssertEqual(BigUInt(328) % BigUInt(21), BigUInt(13))

        var a = BigUInt(328)
        a /= 21
        XCTAssertEqual(a, 15)
        a %= 7
        XCTAssertEqual(a, 1)

        #if false
            for x0 in (0 ... Int(Digit.max)) {
                for x1 in (0 ... Int(Digit.max)).reverse() {
                    for y0 in (0 ... Int(Digit.max)).reverse() {
                        for y1 in (1 ... Int(Digit.max)).reverse() {
                            for x2 in (1 ... y1).reverse() {
                                test(
                                    [Digit(x0), Digit(x1), Digit(x2)],
                                    [Digit(y0), Digit(y1)])
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
            let (div, mod) = remaining.divide(BigUInt(i))
            XCTAssertEqual(mod, 0)
            remaining = div
        }
        XCTAssertEqual(remaining, 1)
    }

    func testSqrt() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        XCTAssertEqual(sqrt(BigUInt(0)), 0)
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

    func testGCD() {
        XCTAssertEqual(BigUInt.gcd(0, 2982891), 0)
        XCTAssertEqual(BigUInt.gcd(2982891, 0), 0)
        XCTAssertEqual(BigUInt.gcd(0, 0), 0)

        XCTAssertEqual(BigUInt.gcd(4, 6), 2)
        XCTAssertEqual(BigUInt.gcd(15, 10), 5)
        XCTAssertEqual(BigUInt.gcd(8 * 3 * 25 * 7, 2 * 9 * 5 * 49), 2 * 3 * 5 * 7)

        var fibo: [BigUInt] = [0, 1]
        for i in 0...10000 {
            fibo.append(fibo[i] + fibo[i + 1])
        }

        XCTAssertEqual(BigUInt.gcd(fibo[100], fibo[101]), 1)
        XCTAssertEqual(BigUInt.gcd(fibo[1000], fibo[1001]), 1)
        XCTAssertEqual(BigUInt.gcd(fibo[10000], fibo[10001]), 1)

        XCTAssertEqual(BigUInt.gcd(3 * 5 * 7 * 9, 5 * 7 * 7), 5 * 7)
        XCTAssertEqual(BigUInt.gcd(fibo[4], fibo[2]), fibo[2])
        XCTAssertEqual(BigUInt.gcd(fibo[3 * 5 * 7 * 9], fibo[5 * 7 * 7 * 9]), fibo[5 * 7 * 9])
        XCTAssertEqual(BigUInt.gcd(fibo[7 * 17 * 83], fibo[6 * 17 * 83]), fibo[17 * 83])
    }

    func testModularExponentiation() {
        XCTAssertEqual(BigUInt.powmod(2, 11, modulus: 1), 0)
        XCTAssertEqual(BigUInt.powmod(2, 11, modulus: 1000), 48)

        func test(a a: BigUInt, p: BigUInt, file: String = __FILE__, line: UInt = __LINE__) {
            // For all primes p and integers a, a % p == a^p % p. (Fermat's Little Theorem)
            let x = a % p
            let y = BigUInt.powmod(x, p, modulus: p)
            XCTAssertEqual(x, y, file: file, line: line)
        }

        // Here are some primes
        let m61 = (BigUInt(1) << 61) - 1
        let m127 = (BigUInt(1) << 127) - 1
        let m521 = (BigUInt(1) << 521) - 1

        test(a: 2, p: m127)
        test(a: 1 << 42, p: m127)
        test(a: 1 << 42 + 1, p: m127)
        test(a: m61, p: m127)
        test(a: m61 + 1, p: m127)
        test(a: m61, p: m521)
        test(a: m61 + 1, p: m521)
        test(a: m127, p: m521)
    }

    func data(bytes: Array<UInt8>) -> NSData {
        var result: NSData? = nil
        bytes.withUnsafeBufferPointer { p in
            result = NSData(bytes: p.baseAddress, length: p.count)
        }
        return result!
    }

    func testConversionFromData() {
        XCTAssertEqual(BigUInt(data([])), 0)
        XCTAssertEqual(BigUInt(data([0])), 0)
        XCTAssertEqual(BigUInt(data([0, 0, 0, 0, 0, 0, 0, 0])), 0)
        XCTAssertEqual(BigUInt(data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])), 0)
        XCTAssertEqual(BigUInt(data([1])), 1)
        XCTAssertEqual(BigUInt(data([2])), 2)
        XCTAssertEqual(BigUInt(data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])), 1)
        XCTAssertEqual(BigUInt(data([0x01, 0x02, 0x03, 0x04, 0x05])), 0x0102030405)
        XCTAssertEqual(BigUInt(data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])), 0x0102030405060708)
        XCTAssertEqual(
            BigUInt(data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A])),
            BigUInt(0x0102) << 64 + BigUInt(0x030405060708090A))
        XCTAssertEqual(
            BigUInt(data([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])),
            BigUInt(1) << 80)
        XCTAssertEqual(
            BigUInt(data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10])),
            BigUInt(0x0102030405060708) << 64 + BigUInt(0x090A0B0C0D0E0F10))

        // The following test produced "expression was too complex" error on Swift 2.2.1
        let d = data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11])
        var b = BigUInt(1) << 128
        b += BigUInt(0x0203040506070809) << 64
        b += BigUInt(0x0A0B0C0D0E0F1011)
        XCTAssertEqual(BigUInt(d), b)
    }

    func testConversionToData() {
        func test(b: BigUInt, _ d: Array<UInt8>, file: String = __FILE__, line: UInt = __LINE__) {
            let expected = data(d)
            let actual = b.serialize()
            XCTAssertEqual(actual, expected, file: file, line: line)
            XCTAssertEqual(BigUInt(actual), b, file: file, line: line)
        }

        test(BigUInt(), [])
        test(BigUInt(1), [0x01])
        test(BigUInt(2), [0x02])
        test(BigUInt(0x0102030405060708), [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(BigUInt(0x01) << 64 + BigUInt(0x0203040506070809), [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])
    }

    func testRandomIntegerWithMaximumWidth() {
        XCTAssertEqual(BigUInt.randomIntegerWithMaximumWidth(0), 0)

        let randomByte = BigUInt.randomIntegerWithMaximumWidth(8)
        XCTAssertLessThan(randomByte, 256)

        for _ in 0 ..< 100 {
            XCTAssertLessThanOrEqual(BigUInt.randomIntegerWithMaximumWidth(1024).width, 1024)
        }

        // Verify that all widths <= maximum are produced
        var widths: Set<Int> = [0, 1, 2, 3]
        var i = 0
        while !widths.isEmpty {
            let random = BigUInt.randomIntegerWithMaximumWidth(3)
            XCTAssertLessThanOrEqual(random.width, 3)
            widths.remove(random.width)
            i += 1
            if i > 4096 {
                XCTFail("randomIntegerWithMaximumWidth doesn't seem random")
                break
            }
        }
    }

    func testRandomIntegerWithExactWidth() {
        XCTAssertEqual(BigUInt.randomIntegerWithExactWidth(0), 0)
        XCTAssertEqual(BigUInt.randomIntegerWithExactWidth(1), 1)

        for _ in 0 ..< 1024 {
            let randomByte = BigUInt.randomIntegerWithExactWidth(8)
            XCTAssertEqual(randomByte.width, 8)
            XCTAssertLessThan(randomByte, 256)
            XCTAssertGreaterThanOrEqual(randomByte, 128)
        }

        for _ in 0 ..< 100 {
            XCTAssertEqual(BigUInt.randomIntegerWithExactWidth(1024).width, 1024)
        }
    }
}