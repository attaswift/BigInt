//
//  BigUIntTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import XCTest
@testable import BigInt

class BigUIntTests: XCTestCase {
    typealias Word = BigUInt.Word

    func testInit() {
        let b0 = BigUInt()
        XCTAssertEqual(b0.words, [])
        
        let b1 = BigUInt(words: [1, 2])
        XCTAssertEqual(b1.words, [1, 2])
        
        let b2 = BigUInt(words: [1, 2, 3, 0, 0])
        XCTAssertEqual(b2.words, [1, 2, 3])
        
        let b3 = BigUInt(words: [12, 34, 56][1 ..< 2])
        XCTAssertEqual(b3.words, [34])
        
        let b5 = BigUInt(UInt64(0x1827364554637281))
        XCTAssertEqual(String(b5, radix: 16), "1827364554637281")

        let b6 = BigUInt(UInt32(0x12345678))
        XCTAssertEqual(String(b6, radix: 16), "12345678")

        let b7 = BigUInt(Int64(0x1827364554637281))
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

    func testInitFromFloats() {
        XCTAssertEqual(BigUInt(exactly: 42.0 as Float), BigUInt(42))
        XCTAssertEqual(BigUInt(exactly: 42.0 as Double), BigUInt(42))

        XCTAssertEqual(BigUInt(exactly: -0.0 as Float), 0 as BigUInt)
        XCTAssertEqual(BigUInt(exactly: -0.0 as Double), 0 as BigUInt)

        XCTAssertNil(BigUInt(exactly: -42.0 as Float))
        XCTAssertNil(BigUInt(exactly: -42.0 as Double))

        XCTAssertNil(BigUInt(exactly: 42.5 as Float))
        XCTAssertNil(BigUInt(exactly: 42.5 as Double))

        XCTAssertNil(BigUInt(exactly: Float.leastNormalMagnitude))
        XCTAssertNil(BigUInt(exactly: Double.leastNormalMagnitude))

        XCTAssertNil(BigUInt(exactly: Float.infinity))
        XCTAssertNil(BigUInt(exactly: Double.infinity))

        XCTAssertNil(BigUInt(exactly: Float.nan))
        XCTAssertNil(BigUInt(exactly: Double.nan))

        XCTAssertEqual(BigUInt(exactly: Float.greatestFiniteMagnitude),
                       "340282346638528859811704183484516925440" as BigUInt)
        XCTAssertEqual(BigUInt(exactly: Double.greatestFiniteMagnitude),
                       "179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368" as BigUInt)
    }

    func testCollection() {
        let b0 = BigUInt()
        XCTAssertEqual(b0.count, 0)
        XCTAssertEqual(b0.words, [])

        let b1 = BigUInt(words: [1])
        XCTAssertEqual(b1.count, 1)
        XCTAssertEqual(b1.words, [1])

        let b2 = BigUInt(words: [0, 1])
        XCTAssertEqual(b2.count, 2)
        XCTAssertEqual(b2.words, [0, 1])

        let b3 = BigUInt(words: [0, 1, 0])
        XCTAssertEqual(b3.count, 2)
        XCTAssertEqual(b3.words, [0, 1])

        let b4 = BigUInt(words: [1, 0, 0, 0])
        XCTAssertEqual(b4.count, 1)
        XCTAssertEqual(b4.words, [1])

        let b5 = BigUInt(words: [0, 0, 0, 0, 0, 0])
        XCTAssertEqual(b5.count, 0)
        XCTAssertEqual(b5.words, [])
    }

    func testSubscriptingGetter() {
        let b = BigUInt(words: [1, 2])
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
        let value = BigUInt(words: [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20])
        let slice = value[3..<6]

        XCTAssertEqual(slice.count, 3)
        XCTAssertEqual(slice.startIndex, 0)
        XCTAssertEqual(slice.endIndex, 3)

        XCTAssertEqual(slice.words, [6, 8, 10])
        XCTAssertEqual(slice[0], 6)
        XCTAssertEqual(slice[1], 8)
        XCTAssertEqual(slice[2], 10)
    }

    func testIntegerArithmeticRequirements() {
        XCTAssertEqual(0, UInt(BigUInt(0)))
        XCTAssertEqual(42, UInt(BigUInt(42)))

        XCTAssertEqual(2, BigUInt(5).subtractingReportingOverflow(3).partialValue)
        XCTAssertEqual(ArithmeticOverflow.none, BigUInt(5).subtractingReportingOverflow(3).overflow)

        XCTAssertEqual(BigUInt(Word.max - 1), BigUInt(3).subtractingReportingOverflow(5).partialValue)
        XCTAssertEqual(ArithmeticOverflow.overflow, BigUInt(3).subtractingReportingOverflow(5).overflow)
    }
    
    func testStrideableRequirements() {
        XCTAssertEqual(BigUInt(10), BigUInt(4).advanced(by: BigInt(6)))
        XCTAssertEqual(BigUInt(4), BigUInt(10).advanced(by: BigInt(-6)))
        XCTAssertEqual(BigInt(6), BigUInt(4).distance(to: 10))
        XCTAssertEqual(BigInt(-6), BigUInt(10).distance(to: 4))
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

        let quickLook = BigUInt(513).customPlaygroundQuickLook
        if case PlaygroundQuickLook.text("513 (10 bits)") = quickLook {
        } else {
            XCTFail("Unexpected playground QuickLook representation: \(quickLook)")
        }
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
        let a = BigUInt(words: [0, 1, 2, 3])
        XCTAssertEqual(a.low, BigUInt(words: [0, 1]))
        XCTAssertEqual(a.high, BigUInt(words: [2, 3]))
        XCTAssertEqual(a.low.low, BigUInt(words: [0]))
        XCTAssertEqual(a.low.high, BigUInt(words: [1]))
        XCTAssertEqual(a.high.low, BigUInt(words: [2]))
        XCTAssertEqual(a.high.high, BigUInt(words: [3]))

        let b = BigUInt(words: [0, 1, 2, 3, 4, 5])

        let bl = b.low
        XCTAssertEqual(bl, BigUInt(words: [0, 1, 2]))
        let bh = b.high
        XCTAssertEqual(bh, BigUInt(words: [3, 4, 5]))

        let bll = bl.low
        XCTAssertEqual(bll, BigUInt(words: [0, 1]))
        let blh = bl.high
        XCTAssertEqual(blh, BigUInt(words: [2, 0]))
        let bhl = bh.low
        XCTAssertEqual(bhl, BigUInt(words: [3, 4]))
        let bhh = bh.high
        XCTAssertEqual(bhh, BigUInt(words: [5, 0]))

        let blhl = bll.low
        XCTAssertEqual(blhl, BigUInt(words: [0]))
        let blhh = bll.high
        XCTAssertEqual(blhh, BigUInt(words: [1]))
        let bhhl = bhl.low
        XCTAssertEqual(bhhl, BigUInt(words: [3]))
        let bhhh = bhl.high
        XCTAssertEqual(bhhh, BigUInt(words: [4]))
    }

    func testComparison() {
        XCTAssertEqual(BigUInt(words: [1, 2, 3]), BigUInt(words: [1, 2, 3]))
        XCTAssertNotEqual(BigUInt(words: [1, 2]), BigUInt(words: [1, 2, 3]))
        XCTAssertNotEqual(BigUInt(words: [1, 2, 3]), BigUInt(words: [1, 3, 3]))
        XCTAssertEqual(BigUInt(words: [1, 2, 3, 4, 5, 6]).low.high, BigUInt(words: [3]))

        XCTAssertTrue(BigUInt(words: [1, 2]) < BigUInt(words: [1, 2, 3]))
        XCTAssertTrue(BigUInt(words: [1, 2, 2]) < BigUInt(words: [1, 2, 3]))
        XCTAssertFalse(BigUInt(words: [1, 2, 3]) < BigUInt(words: [1, 2, 3]))
        XCTAssertTrue(BigUInt(words: [3, 3]) < BigUInt(words: [1, 2, 3, 4, 5, 6])[2..<4])
        XCTAssertTrue(BigUInt(words: [1, 2, 3, 4, 5, 6]).low.high < BigUInt(words: [3, 5]))
    }

    func testIsZero() {
        let b = BigUInt(words: [0, 0, 0, 1])

        XCTAssertFalse(b.isZero)
        XCTAssertTrue(b.low.isZero)
        XCTAssertTrue(b.high.low.isZero)
        XCTAssertFalse(b.high.high.isZero)
    }

    func testHashing() {
        var hashes: [Int] = []
        hashes.append(BigUInt(words: []).hashValue)
        hashes.append(BigUInt(words: [1]).hashValue)
        hashes.append(BigUInt(words: [2]).hashValue)
        hashes.append(BigUInt(words: [0, 1]).hashValue)
        hashes.append(BigUInt(words: [1, 1]).hashValue)
        hashes.append(BigUInt(words: [1, 2]).hashValue)
        hashes.append(BigUInt(words: [2, 1]).hashValue)
        hashes.append(BigUInt(words: [2, 2]).hashValue)
        hashes.append(BigUInt(words: [1, 2, 3, 4, 5]).hashValue)
        hashes.append(BigUInt(words: [5, 4, 3, 2, 1]).hashValue)
        hashes.append(BigUInt(words: [Word.max]).hashValue)
        hashes.append(BigUInt(words: [Word.max, Word.max]).hashValue)
        hashes.append(BigUInt(words: [Word.max, Word.max, Word.max]).hashValue)
        hashes.append(BigUInt(words: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).hashValue)
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

        let ffff = BigUInt(words: Array(repeating: Word.max, count: 30))
        let not = ~ffff
        let zero = BigUInt()
        XCTAssertEqual(not, zero)
        XCTAssertEqual((~ffff).words, BigUInt(0).words)
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
        XCTAssertEqual(BigUInt(0) + BigUInt(Word.max), BigUInt(Word.max))
        XCTAssertEqual(BigUInt(Word.max) + BigUInt(1), BigUInt(words: [0, 1]))

        var b = BigUInt()
        XCTAssertEqual(b, 0)

        b.add(BigUInt(Word.max))
        XCTAssertEqual(b, BigUInt(Word.max))

        b.add(1)
        XCTAssertEqual(b, BigUInt(words: [0, 1]))

        b.add(BigUInt(words: [3, 4]))
        XCTAssertEqual(b, BigUInt(words: [3, 5]))

        b.add(BigUInt(words: [0, Word.max]))
        XCTAssertEqual(b, BigUInt(words: [3, 4, 1]))

        b.add(BigUInt(words: [0, Word.max]))
        XCTAssertEqual(b, BigUInt(words: [3, 3, 2]))

        b += 2
        XCTAssertEqual(b, BigUInt(words: [5, 3, 2]))

        b = BigUInt(words: [Word.max, 2, Word.max])
        b.increment()
        XCTAssertEqual(b, BigUInt(words: [0, 3, Word.max]))

        XCTAssertEqual(BigUInt(words: [Word.max - 5, Word.max, 4, Word.max]).addingWord(6), BigUInt(words: [0, 0, 5, Word.max]))

    }

    func testShiftedAddition() {
        var b = BigUInt()
        b.add(1, shiftedBy: 1)
        XCTAssertEqual(b, BigUInt(words: [0, 1]))

        b.add(2, shiftedBy: 3)
        XCTAssertEqual(b, BigUInt(words: [0, 1, 0, 2]))

        b.add(BigUInt(Word.max), shiftedBy: 1)
        XCTAssertEqual(b, BigUInt(words: [0, 0, 1, 2]))
    }

    func testSubtraction() {
        var a1 = BigUInt(words: [1, 2, 3, 4])
        XCTAssertEqual(ArithmeticOverflow.none, a1.subtractWordReportingOverflow(3, shiftedBy: 1))
        XCTAssertEqual(a1, BigUInt(words: [1, Word.max, 2, 4]))

        let (diff, overflow) = BigUInt(words: [1, 2, 3, 4]).subtractingWordReportingOverflow(2)
        XCTAssertEqual(diff, BigUInt(words: [Word.max, 1, 3, 4]))
        XCTAssertEqual(ArithmeticOverflow.none, overflow)

        var a2 = BigUInt(words: [1, 2, 3, 4])
        XCTAssertEqual(ArithmeticOverflow.overflow, a2.subtractWordReportingOverflow(5, shiftedBy: 3))
        XCTAssertEqual(a2, BigUInt(words: [1, 2, 3, Word.max]))

        var a3 = BigUInt(words: [1, 2, 3, 4])
        a3.subtractWord(4, shiftedBy: 3)
        XCTAssertEqual(a3, BigUInt(words: [1, 2, 3]))

        var a4 = BigUInt(words: [1, 2, 3, 4])
        a4.decrement()
        XCTAssertEqual(a4, BigUInt(words: [0, 2, 3, 4]))
        a4.decrement()
        XCTAssertEqual(a4, BigUInt(words: [Word.max, 1, 3, 4]))

        XCTAssertEqual(BigUInt(words: [1, 2, 3, 4]).subtractingWord(5), BigUInt(words: [Word.max - 3, 1, 3, 4]))

        XCTAssertEqual(BigUInt(0) - BigUInt(0), BigUInt(0))

        var b = BigUInt(words: [1, 2, 3, 4])
        XCTAssertEqual(ArithmeticOverflow.none, b.subtractReportingOverflow(BigUInt(words: [0, 1, 1, 1])))
        XCTAssertEqual(b.words, [1, 1, 2, 3])

        let b1 = BigUInt(words: [1, 1, 2, 3]).subtractingReportingOverflow(BigUInt(words: [1, 1, 3, 3]))
        XCTAssertEqual(b1.0, BigUInt(words: [0, 0, Word.max, Word.max]))
        XCTAssertEqual(ArithmeticOverflow.overflow, b1.1)

        let b2 = BigUInt(words: [0, 0, 1]) - BigUInt(words: [1])
        XCTAssertEqual(b2.words, [Word.max, Word.max])

        var b3 = BigUInt(words: [1, 0, 0, 1])
        b3 -= 2
        XCTAssertEqual(b3.words, [Word.max, Word.max, Word.max])
    }

    func testMultiplyByWord() {
        XCTAssertEqual(BigUInt(words: [1, 2, 3, 4]).multiplied(byWord: 0), BigUInt(0))
        XCTAssertEqual(BigUInt(words: [1, 2, 3, 4]).multiplied(byWord: 2), BigUInt(words: [2, 4, 6, 8]))

        let full = Word.max

        let b = BigUInt(words: [full, 0, full, 0, full]).multiplied(byWord: 2)
        XCTAssertEqual(b, BigUInt(words: [full - 1, 1, full - 1, 1, full - 1, 1]))

        let c = BigUInt(words: [full, full, full]).multiplied(byWord: 2)
        XCTAssertEqual(c, BigUInt(words: [full - 1, full, full, 1]))

        let d = BigUInt(words: [full, full, full]).multiplied(byWord: full)
        XCTAssertEqual(d, BigUInt(words: [1, full, full, full - 1]))

        let e = BigUInt("11111111111111111111111111111111", radix: 16)!.multiplied(byWord: 15)
        XCTAssertEqual(e, BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", radix: 16)!)

        let f = BigUInt("11111111111111111111111111111112", radix: 16)!.multiplied(byWord: 15)
        XCTAssertEqual(f, BigUInt("10000000000000000000000000000000E", radix: 16)!)
    }

    func testMultiplication() {
        func test() {
            XCTAssertEqual(
                BigUInt(words: [1, 2, 3, 4]) * BigUInt(),
                BigUInt())
            XCTAssertEqual(
                BigUInt() * BigUInt(words: [1, 2, 3, 4]),
                BigUInt())
            XCTAssertEqual(
                BigUInt(words: [1, 2, 3, 4]) * BigUInt(words: [2]),
                BigUInt(words: [2, 4, 6, 8]))
            XCTAssertEqual(
                BigUInt(words: [1, 2, 3, 4]).multiplied(by: BigUInt(words: [2])),
                BigUInt(words: [2, 4, 6, 8]))
            XCTAssertEqual(
                BigUInt(words: [2]) * BigUInt(words: [1, 2, 3, 4]),
                BigUInt(words: [2, 4, 6, 8]))
            XCTAssertEqual(
                BigUInt(words: [1, 2, 3, 4]) * BigUInt(words: [0, 1]),
                BigUInt(words: [0, 1, 2, 3, 4]))
            XCTAssertEqual(
                BigUInt(words: [0, 1]) * BigUInt(words: [1, 2, 3, 4]),
                BigUInt(words: [0, 1, 2, 3, 4]))
            XCTAssertEqual(
                BigUInt(words: [4, 3, 2, 1]) * BigUInt(words: [1, 2, 3, 4]),
                BigUInt(words: [4, 11, 20, 30, 20, 11, 4]))
            // 999 * 99 = 98901
            XCTAssertEqual(
                BigUInt(words: [Word.max, Word.max, Word.max]) * BigUInt(words: [Word.max, Word.max]),
                BigUInt(words: [1, 0, Word.max, Word.max - 1, Word.max]))
            XCTAssertEqual(
                BigUInt(words: [1, 2]) * BigUInt(words: [2, 1]),
                BigUInt(words: [2, 5, 2]))

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
        a <<= Word.bitWidth
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a[0], 0)
        XCTAssertEqual(a[1...sample.count + 1].words, sample.words) // FIXME slice

        a = sample
        a <<= 100 * Word.bitWidth
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a[0..<100], 0)
        XCTAssertEqual(a[100...sample.count + 100].words, sample.words) // FIXME slice

        a = sample
        a <<= 100 * Word.bitWidth + 2
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a[0..<100], 0)
        XCTAssertEqual(a[100...sample.count + 100].words, (sample << 2).words) // FIXME slice

        a = sample
        a <<= Word.bitWidth - 1
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a, BigUInt(words: [0] + sample.words) / 2)


        a = sample
        a <<= -4
        XCTAssertEqual(a, sample / 16)

        XCTAssertEqual(sample << 0, sample)
        XCTAssertEqual(sample << 1, 2 * sample)
        XCTAssertEqual(sample << 2, 4 * sample)
        XCTAssertEqual(sample << 4, 16 * sample)
        XCTAssertEqual(sample << Word.bitWidth, BigUInt(words: [0 as Word] + sample.words))
        XCTAssertEqual(sample << (Word.bitWidth - 1), BigUInt(words: [0] + sample.words) / 2)
        XCTAssertEqual(sample << (Word.bitWidth + 1), BigUInt(words: [0] + sample.words) * 2)
        XCTAssertEqual(sample << (Word.bitWidth + 2), BigUInt(words: [0] + sample.words) * 4)
        XCTAssertEqual(sample << (2 * Word.bitWidth), BigUInt(words: [0, 0] + sample.words))
        XCTAssertEqual(sample << (2 * Word.bitWidth + 2), BigUInt(words: [0, 0] + (4 * sample).words))

        XCTAssertEqual(sample << -1, sample / 2)
        XCTAssertEqual(sample << -4, sample / 16)
    }

    func testMaskedLeftShifts() {
        let sample = BigUInt("123456789ABCDEF01234567891631832727633", radix: 16)!

        var a = sample

        a &<<= 0
        XCTAssertEqual(a, sample)

        a = sample
        a &<<= 1
        XCTAssertEqual(a, 2 * sample)

        a = sample
        a &<<= Word.bitWidth
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a[0], 0)
        XCTAssertEqual(a[1...sample.count + 1], sample)

        a = sample
        a &<<= 100 * Word.bitWidth
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a[0..<100], 0)
        XCTAssertEqual(a[100...sample.count + 100], sample)

        a = sample
        a &<<= 100 * Word.bitWidth + 2
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a[0..<100], 0)
        XCTAssertEqual(a[100...sample.count + 100], sample << 2)

        a = sample
        a &<<= Word.bitWidth - 1
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a, BigUInt(words: [0] + sample.words) / 2)

        XCTAssertEqual(sample &<< 0, sample)
        XCTAssertEqual(sample &<< 1, 2 * sample)
        XCTAssertEqual(sample &<< 2, 4 * sample)
        XCTAssertEqual(sample &<< 4, 16 * sample)
        XCTAssertEqual(sample &<< Word.bitWidth, BigUInt(words: [0 as Word] + sample.words))
        XCTAssertEqual(sample &<< (Word.bitWidth - 1), BigUInt(words: [0] + sample.words) / 2)
        XCTAssertEqual(sample &<< (Word.bitWidth + 1), BigUInt(words: [0] + sample.words) * 2)
        XCTAssertEqual(sample &<< (Word.bitWidth + 2), BigUInt(words: [0] + sample.words) * 4)
        XCTAssertEqual(sample &<< (2 * Word.bitWidth), BigUInt(words: [0, 0] + sample.words))
        XCTAssertEqual(sample &<< (2 * Word.bitWidth + 2), BigUInt(words: [0, 0] + (4 * sample).words))
    }

    func testRightShifts() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        var a = sample

        a >>= BigUInt(0)
        XCTAssertEqual(a, sample)

        a >>= 0
        XCTAssertEqual(a, sample)

        a = sample
        a >>= 1
        XCTAssertEqual(a, sample / 2)

        a = sample
        a >>= Word.bitWidth
        XCTAssertEqual(a, sample[1...])

        a = sample
        a >>= Word.bitWidth + 2
        XCTAssertEqual(a, sample[1...] / 4)

        a = sample
        a >>= sample.count * Word.bitWidth
        XCTAssertEqual(a, 0)

        a = sample
        a >>= 1000
        XCTAssertEqual(a, 0)

        a = sample
        a >>= 100 * Word.bitWidth
        XCTAssertEqual(a, 0)

        a = sample
        a >>= 100 * BigUInt(Word.max)
        XCTAssertEqual(a, 0)

        a = sample
        a >>= -1
        XCTAssertEqual(a, sample * 2)

        a = sample
        a >>= -4
        XCTAssertEqual(a, sample * 16)

        XCTAssertEqual(sample >> BigUInt(0), sample)
        XCTAssertEqual(sample >> 0, sample)
        XCTAssertEqual(sample >> 1, sample / 2)
        XCTAssertEqual(sample >> 3, sample / 8)
        XCTAssertEqual(sample >> Word.bitWidth, sample[1..<sample.count])
        XCTAssertEqual(sample >> (Word.bitWidth + 2), sample[1...] / 4)
        XCTAssertEqual(sample >> (Word.bitWidth + 3), sample[1...] / 8)
        XCTAssertEqual(sample >> (sample.count * Word.bitWidth), 0)
        XCTAssertEqual(sample >> (100 * Word.bitWidth), 0)
        XCTAssertEqual(sample >> (100 * BigUInt(Word.max)), 0)

        XCTAssertEqual(sample >> -1, sample * 2)
        XCTAssertEqual(sample >> -4, sample * 16)
    }

    func testMaskedRightShifts() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        var a = sample

        a &>>= 0
        XCTAssertEqual(a, sample)

        a = sample
        a &>>= 1
        XCTAssertEqual(a, sample / 2)

        a = sample
        a &>>= Word.bitWidth
        XCTAssertEqual(a, sample[1...])

        a = sample
        a &>>= BigUInt(Word.bitWidth + 2)
        XCTAssertEqual(a, sample[1...] / 4)

        a = sample
        a &>>= sample.count * Word.bitWidth
        XCTAssertEqual(a, 0)

        a = sample
        a &>>= 1000
        XCTAssertEqual(a, 0)

        XCTAssertEqual(sample &>> 0, sample)
        XCTAssertEqual(sample &>> 1, sample / 2)
        XCTAssertEqual(sample &>> 3, sample / 8)
        XCTAssertEqual(sample &>> Word.bitWidth, sample[1..<sample.count])
        XCTAssertEqual(sample &>> (Word.bitWidth + 2), sample[1...] / 4)
        XCTAssertEqual(sample &>> (Word.bitWidth + 3), sample[1...] / 8)
        XCTAssertEqual(sample &>> (sample.count * Word.bitWidth), 0)
        XCTAssertEqual(sample &>> (100 * Word.bitWidth), 0)
    }

    func testWidth() {
        XCTAssertEqual(BigUInt(0).bitWidth, 0)
        XCTAssertEqual(BigUInt(1).bitWidth, 1)
        XCTAssertEqual(BigUInt(Word.max).bitWidth, Word.bitWidth)
        XCTAssertEqual(BigUInt(words: [Word.max, 1]).bitWidth, Word.bitWidth + 1)
        XCTAssertEqual(BigUInt(words: [2, 12]).bitWidth, Word.bitWidth + 4)
        XCTAssertEqual(BigUInt(words: [1, Word.max]).bitWidth, 2 * Word.bitWidth)

        XCTAssertEqual(BigUInt(0).leadingZeroBitCount, 0)
        XCTAssertEqual(BigUInt(1).leadingZeroBitCount, Word.bitWidth - 1)
        XCTAssertEqual(BigUInt(Word.max).leadingZeroBitCount, 0)
        XCTAssertEqual(BigUInt(words: [Word.max, 1]).leadingZeroBitCount, Word.bitWidth - 1)
        XCTAssertEqual(BigUInt(words: [14, Word.max]).leadingZeroBitCount, 0)

        XCTAssertEqual(BigUInt(0).trailingZeroBitCount, 0)
        XCTAssertEqual(BigUInt((1 as Word) << (Word.bitWidth - 1)).trailingZeroBitCount, Word.bitWidth - 1)
        XCTAssertEqual(BigUInt(Word.max).trailingZeroBitCount, 0)
        XCTAssertEqual(BigUInt(words: [0, 1]).trailingZeroBitCount, Word.bitWidth)
        XCTAssertEqual(BigUInt(words: [0, 1 << Word(Word.bitWidth - 1)]).trailingZeroBitCount, 2 * Word.bitWidth - 1)
    }

    func testDivision() {
        func test(_ a: [Word], _ b: [Word], file: StaticString = #file, line: UInt = #line) {
            let x = BigUInt(words: a)
            let y = BigUInt(words: b)
            let (div, mod) = x.quotientAndRemainder(dividingBy: y)
            if mod >= y {
                XCTFail("x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            }
            if div * y + mod != x {
                XCTFail("x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            }
        }
        // These cases exercise all code paths in the division when Word is UInt8 or UInt64.
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
        test([Word.max, Word.max - 1, Word.max], [Word.max, Word.max])
        test([0, Word.max, Word.max - 1], [Word.max, Word.max])
        test([0, 0, 0, 0, 0, Word.max / 2 + 1, Word.max / 2], [1, 0, 0, Word.max / 2 + 1])
        test([0, Word.max - 1, Word.max / 2 + 1], [Word.max, Word.max / 2 + 1])
        test([0, 0, 0x41 << Word(Word.bitWidth - 8)], [Word.max, 1 << Word(Word.bitWidth - 1)])

        XCTAssertEqual(BigUInt(328) / BigUInt(21), BigUInt(15))
        XCTAssertEqual(BigUInt(328) % BigUInt(21), BigUInt(13))

        var a = BigUInt(328)
        a /= 21
        XCTAssertEqual(a, 15)
        a %= 7
        XCTAssertEqual(a, 1)

        #if false
            for x0 in (0 ... Int(Word.max)) {
                for x1 in (0 ... Int(Word.max)).reverse() {
                    for y0 in (0 ... Int(Word.max)).reverse() {
                        for y1 in (1 ... Int(Word.max)).reverse() {
                            for x2 in (1 ... y1).reverse() {
                                test(
                                    [Word(x0), Word(x1), Word(x2)],
                                    [Word(y0), Word(y1)])
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
        for i in (1 ..< (1 << power)).reversed() {
            backward *= BigUInt(i)
        }

        func balancedFactorial(level: Int, offset: Int) -> BigUInt {
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
            let (div, mod) = remaining.quotientAndRemainder(dividingBy: BigUInt(i))
            XCTAssertEqual(mod, 0)
            remaining = div
        }
        XCTAssertEqual(remaining, 1)
    }

    func testSquareRoot() {
        let sample = BigUInt("123456789ABCDEF1234567891631832727633", radix: 16)!

        XCTAssertEqual(BigUInt(0).squareRoot(), 0)
        XCTAssertEqual(BigUInt(256).squareRoot(), 16)

        func checkSqrt(_ value: BigUInt, file: StaticString = #file, line: UInt = #line) {
            let root = sample.squareRoot()
            XCTAssertLessThanOrEqual(root * root, sample, file: file, line: line)
            XCTAssertGreaterThan((root + 1) * (root + 1), sample, file: file, line: line)
        }
        checkSqrt(sample)
        checkSqrt(sample * sample)
        checkSqrt(sample * sample - 1)
        checkSqrt(sample * sample + 1)
    }

    func testGCD() {
        XCTAssertEqual(BigUInt.gcd(0, 2982891), 2982891)
        XCTAssertEqual(BigUInt.gcd(2982891, 0), 2982891)
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
    
    #if false // FIXME
    func testInverse() {
        XCTAssertNil(BigUInt(4).inverse(8))
        XCTAssertNil(BigUInt(12).inverse(15))
        XCTAssertEqual(BigUInt(13).inverse(15), 7)
        
        XCTAssertEqual(BigUInt(251).inverse(1023), 269)
        XCTAssertNil(BigUInt(252).inverse(1023))
        XCTAssertEqual(BigUInt(2).inverse(1023), 512)
    }
    #endif

    func testExponentiation() {
        XCTAssertEqual(BigUInt(0).power(0), BigUInt(1))
        XCTAssertEqual(BigUInt(1).power(0), BigUInt(1))
        XCTAssertEqual(BigUInt(0).power(1), BigUInt(0))
        XCTAssertEqual(BigUInt(1).power(1), BigUInt(1))

        XCTAssertEqual(BigUInt(2).power(0), BigUInt(1))
        XCTAssertEqual(BigUInt(2).power(1), BigUInt(2))
        XCTAssertEqual(BigUInt(2).power(2), BigUInt(4))
        XCTAssertEqual(BigUInt(2).power(3), BigUInt(8))

        XCTAssertEqual(BigUInt(3).power(0), BigUInt(1))
        XCTAssertEqual(BigUInt(3).power(1), BigUInt(3))
        XCTAssertEqual(BigUInt(3).power(2), BigUInt(9))
        XCTAssertEqual(BigUInt(3).power(3), BigUInt(27))

        XCTAssertEqual((BigUInt(1) << 256).power(0), BigUInt(1))
        XCTAssertEqual((BigUInt(1) << 256).power(1), BigUInt(1) << 256)
        XCTAssertEqual((BigUInt(1) << 256).power(2), BigUInt(1) << 512)

        XCTAssertEqual(BigUInt(0).power(577), BigUInt(0))
        XCTAssertEqual(BigUInt(1).power(577), BigUInt(1))
        XCTAssertEqual(BigUInt(2).power(577), BigUInt(1) << 577)
    }

    func testModularExponentiation() {
        XCTAssertEqual(BigUInt(2).power(11, modulus: 1), 0)
        XCTAssertEqual(BigUInt(2).power(11, modulus: 1000), 48)

        func test(a: BigUInt, p: BigUInt, file: StaticString = #file, line: UInt = #line) {
            // For all primes p and integers a, a % p == a^p % p. (Fermat's Little Theorem)
            let x = a % p
            let y = x.power(p, modulus: p)
            XCTAssertEqual(x, y, file: file, line: line)
        }

        // Here are some primes

        let m61 = (BigUInt(1) << 61) - BigUInt(1)
        let m127 = (BigUInt(1) << 127) - BigUInt(1)
        let m521 = (BigUInt(1) << 521) - BigUInt(1)

        test(a: 2, p: m127)
        test(a: BigUInt(1) << 42, p: m127)
        test(a: BigUInt(1) << 42 + BigUInt(1), p: m127)
        test(a: m61, p: m127)
        test(a: m61 + 1, p: m127)
        test(a: m61, p: m521)
        test(a: m61 + 1, p: m521)
        test(a: m127, p: m521)
    }

    func data(_ bytes: Array<UInt8>) -> Data {
        var result: Data? = nil
        bytes.withUnsafeBufferPointer { p in
            result = Data(bytes: UnsafePointer<UInt8>(p.baseAddress!), count: p.count)
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
        func test(_ b: BigUInt, _ d: Array<UInt8>, file: StaticString = #file, line: UInt = #line) {
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
        XCTAssertEqual(BigUInt.randomInteger(withMaximumWidth: 0), 0)

        let randomByte = BigUInt.randomInteger(withMaximumWidth: 8)
        XCTAssertLessThan(randomByte, 256)

        for _ in 0 ..< 100 {
            XCTAssertLessThanOrEqual(BigUInt.randomInteger(withMaximumWidth: 1024).bitWidth, 1024)
        }

        // Verify that all widths <= maximum are produced (with a tiny maximum)
        var widths: Set<Int> = [0, 1, 2, 3]
        var i = 0
        while !widths.isEmpty {
            let random = BigUInt.randomInteger(withMaximumWidth: 3)
            XCTAssertLessThanOrEqual(random.bitWidth, 3)
            widths.remove(random.bitWidth)
            i += 1
            if i > 4096 {
                XCTFail("randomIntegerWithMaximumWidth doesn't seem random")
                break
            }
        }

        // Verify that all bits are sometimes zero, sometimes one.
        var oneBits = Set<Int>(0..<1024)
        var zeroBits = Set<Int>(0..<1024)
        while !oneBits.isEmpty || !zeroBits.isEmpty {
            var random = BigUInt.randomInteger(withMaximumWidth: 1024)
            for i in 0..<1024 {
                if random[0] & 1 == 1 { oneBits.remove(i) }
                else { zeroBits.remove(i) }
                random >>= 1
            }
        }
    }

    func testRandomIntegerWithExactWidth() {
        XCTAssertEqual(BigUInt.randomInteger(withExactWidth: 0), 0)
        XCTAssertEqual(BigUInt.randomInteger(withExactWidth: 1), 1)

        for _ in 0 ..< 1024 {
            let randomByte = BigUInt.randomInteger(withExactWidth: 8)
            XCTAssertEqual(randomByte.bitWidth, 8)
            XCTAssertLessThan(randomByte, 256)
            XCTAssertGreaterThanOrEqual(randomByte, 128)
        }

        for _ in 0 ..< 100 {
            XCTAssertEqual(BigUInt.randomInteger(withExactWidth: 1024).bitWidth, 1024)
        }

        // Verify that all bits except the top are sometimes zero, sometimes one.
        var oneBits = Set<Int>(0..<1023)
        var zeroBits = Set<Int>(0..<1023)
        while !oneBits.isEmpty || !zeroBits.isEmpty {
            var random = BigUInt.randomInteger(withExactWidth: 1024)
            for i in 0..<1023 {
                if random[0] & 1 == 1 { oneBits.remove(i) }
                else { zeroBits.remove(i) }
                random >>= 1
            }
        }
    }

    func testRandomIntegerLessThan() {
        // Verify that all bits in random integers generated by `randomIntegerLessThan` are sometimes zero, sometimes one.
        //
        // The limit starts with "11" so that generated random integers may easily begin with all combos.
        // Also, 25% of the time the initial random int will be rejected as higher than the 
        // limit -- this helps stabilize code coverage.
        let limit = BigUInt(3) << 1024
        var oneBits = Set<Int>(0..<limit.bitWidth)
        var zeroBits = Set<Int>(0..<limit.bitWidth)
        for _ in 0..<100 {
            var random = BigUInt.randomInteger(lessThan: limit)
            XCTAssertLessThan(random, limit)
            for i in 0..<limit.bitWidth {
                if random[0] & 1 == 1 { oneBits.remove(i) }
                else { zeroBits.remove(i) }
                random >>= 1
            }
        }
        XCTAssertEqual(oneBits, [])
        XCTAssertEqual(zeroBits, [])
    }

    func testStrongProbablePrimeTest() {
        let primes: [BigUInt.Word] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 79, 83, 89, 97]
        let pseudoPrimes: [BigUInt] = [
            /*  2 */ 2_047,
            /*  3 */ 1_373_653,
            /*  5 */ 25_326_001,
            /*  7 */ 3_215_031_751,
            /* 11 */ 2_152_302_898_747,
            /* 13 */ 3_474_749_660_383,
            /* 17 */ 341_550_071_728_321,
            /* 19 */ 341_550_071_728_321,
            /* 23 */ 3_825_123_056_546_413_051,
            /* 29 */ 3_825_123_056_546_413_051,
            /* 31 */ 3_825_123_056_546_413_051,
            /* 37 */ "318665857834031151167461",
            /* 41 */ "3317044064679887385961981",
        ]
        for i in 0..<pseudoPrimes.count {
            let candidate = pseudoPrimes[i]
            print(candidate)
            // SPPT should not rule out candidate's primality for primes less than prime[i + 1]
            for j in 0...i {
                XCTAssertTrue(candidate.isStrongProbablePrime(BigUInt(primes[j])))
            }
            // But the pseudoprimes aren't prime, so there is a base that disproves them.
            let foo = (i + 1 ... i + 3).filter { !candidate.isStrongProbablePrime(BigUInt(primes[$0])) }
            XCTAssertNotEqual(foo, [])
        }

        // Try the SPPT for some Mersenne numbers.

        // Mersenne exponents from OEIS: https://oeis.org/A000043
        XCTAssertFalse((BigUInt(1) << 606 - BigUInt(1)).isStrongProbablePrime(5))
        XCTAssertTrue((BigUInt(1) << 607 - BigUInt(1)).isStrongProbablePrime(5)) // 2^607 - 1 is prime
        XCTAssertFalse((BigUInt(1) << 608 - BigUInt(1)).isStrongProbablePrime(5))

        XCTAssertFalse((BigUInt(1) << 520 - BigUInt(1)).isStrongProbablePrime(7))
        XCTAssertTrue((BigUInt(1) << 521 - BigUInt(1)).isStrongProbablePrime(7)) // 2^521 -1 is prime
        XCTAssertFalse((BigUInt(1) << 522 - BigUInt(1)).isStrongProbablePrime(7))

        XCTAssertFalse((BigUInt(1) << 88 - BigUInt(1)).isStrongProbablePrime(128))
        XCTAssertTrue((BigUInt(1) << 89 - BigUInt(1)).isStrongProbablePrime(128)) // 2^89 -1 is prime
        XCTAssertFalse((BigUInt(1) << 90 - BigUInt(1)).isStrongProbablePrime(128))

        // One extra test to exercise an a^2 % modulus == 1 case
        XCTAssertFalse(BigUInt(217).isStrongProbablePrime(129))
    }

    func testIsPrime() {
        XCTAssertFalse(BigUInt(0).isPrime())
        XCTAssertFalse(BigUInt(1).isPrime())
        XCTAssertTrue(BigUInt(2).isPrime())
        XCTAssertTrue(BigUInt(3).isPrime())
        XCTAssertFalse(BigUInt(4).isPrime())
        XCTAssertTrue(BigUInt(5).isPrime())

        // Try primality testing the first couple hundred Mersenne numbers comparing against the first few Mersenne exponents from OEIS: https://oeis.org/A000043
        let mp: Set<Int> = [2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521]
        for exponent in 2..<200 {
            let m = BigUInt(1) << exponent - 1
            XCTAssertEqual(m.isPrime(), mp.contains(exponent), "\(exponent)")
        }
    }
}
