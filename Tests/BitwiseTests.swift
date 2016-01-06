//
//  BitwiseTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

class BitwiseTests: XCTestCase {

    func testUInt8_high_low() {
        let n: UInt8 = 0x12
        XCTAssertEqual(n.high, 0x1)
        XCTAssertEqual(n.low, 0x2)
        XCTAssertEqual(n.split.low, n.low)
        XCTAssertEqual(n.split.high, n.high)
    }

    func testUInt16_high_low() {
        let n: UInt16 = 0x1234
        XCTAssertEqual(n.high, 0x12)
        XCTAssertEqual(n.low, 0x34)
        XCTAssertEqual(n.split.low, n.low)
        XCTAssertEqual(n.split.high, n.high)
    }
    func testUInt32_high_low() {
        let n: UInt32 = 0x12345678
        XCTAssertEqual(n.high, 0x1234)
        XCTAssertEqual(n.low, 0x5678)
        XCTAssertEqual(n.split.low, n.low)
        XCTAssertEqual(n.split.high, n.high)
    }
    func testUInt64_high_low() {
        let n: UInt64 = 0x0123456789ABCDEF
        XCTAssertEqual(n.high, 0x01234567)
        XCTAssertEqual(n.low, 0x89ABCDEF)
        XCTAssertEqual(n.split.low, n.low)
        XCTAssertEqual(n.split.high, n.high)
    }
    func testUInt_high_low() {
        let n: UInt = 0x0123456789ABCDEF
        XCTAssertEqual(n.high, 0x01234567)
        XCTAssertEqual(n.low, 0x89ABCDEF)
        XCTAssertEqual(n.split.low, n.low)
        XCTAssertEqual(n.split.high, n.high)
    }

    func testTables() {
        XCTAssertEqual(leadingZeroesTable.count, 256)
        XCTAssertEqual(trailingZeroesTable.count, 256)
    }

    func testUInt8_leadingZeroes() {
        for i in 0...255 {
            let v = UInt8(i)
            let leading = UInt8(v.leadingZeroes)

            guard v != 0 else { XCTAssertEqual(leading, 8); continue }

            XCTAssertLessThanOrEqual(leading, 8)
            XCTAssertEqual((v << leading) >> leading, v)
            XCTAssertNotEqual((v << leading) & 0x80, 0)
        }
    }

    func testUInt8_trailingZeroes() {
        for i in 0...255 {
            let v = UInt8(i)
            let trailing = UInt8(v.trailingZeroes)

            guard v != 0 else { XCTAssertEqual(trailing, 8); continue }

            XCTAssertLessThanOrEqual(trailing, 8)
            XCTAssertEqual((v >> trailing) << trailing, v)
            XCTAssertNotEqual((v >> trailing) & 0x01, 0, "v = \(v)")
        }
    }

    func testUInt16_leadingZeroes() {
        XCTAssertEqual(UInt16.max.leadingZeroes, 0)
        XCTAssertEqual(UInt16(0x01FF).leadingZeroes, 7)
        XCTAssertEqual(UInt16(0x008F).leadingZeroes, 8)
        XCTAssertEqual(UInt16(0x007F).leadingZeroes, 9)
        XCTAssertEqual(UInt16(0x0000).leadingZeroes, 16)
    }

    func testUInt32_leadingZeroes() {
        XCTAssertEqual(UInt32.max.leadingZeroes, 0)
        XCTAssertEqual(UInt32(0x0001FFFF).leadingZeroes, 15)
        XCTAssertEqual(UInt32(0x00008FFF).leadingZeroes, 16)
        XCTAssertEqual(UInt32(0x00007FFF).leadingZeroes, 17)
        XCTAssertEqual(UInt32(0x00000000).leadingZeroes, 32)
    }

    func testUInt64_leadingZeroes() {
        XCTAssertEqual(UInt64.max.leadingZeroes, 0)
        XCTAssertEqual(UInt64(0x00000001FFFFFFFF).leadingZeroes, 31)
        XCTAssertEqual(UInt64(0x000000008FFFFFFF).leadingZeroes, 32)
        XCTAssertEqual(UInt64(0x000000007FFFFFFF).leadingZeroes, 33)
        XCTAssertEqual(UInt64(0x0000000000000000).leadingZeroes, 64)
    }

    func testUInt_leadingZeroes() {
        XCTAssertEqual(UInt.max.leadingZeroes, 0)
        XCTAssertEqual(UInt(0x00000001FFFFFFFF).leadingZeroes, 31)
        XCTAssertEqual(UInt(0x000000008FFFFFFF).leadingZeroes, 32)
        XCTAssertEqual(UInt(0x000000007FFFFFFF).leadingZeroes, 33)
        XCTAssertEqual(UInt(0x0000000000000000).leadingZeroes, 64)
    }

    func testUInt16_trailingZeroes() {
        XCTAssertEqual(UInt16.max.trailingZeroes, 0)
        XCTAssertEqual(UInt16(0xFF80).trailingZeroes, 7)
        XCTAssertEqual(UInt16(0xFF00).trailingZeroes, 8)
        XCTAssertEqual(UInt16(0xFE00).trailingZeroes, 9)
        XCTAssertEqual(UInt16(0x0000).trailingZeroes, 16)
    }

    func testUInt32_trailingZeroes() {
        XCTAssertEqual(UInt32.max.trailingZeroes, 0)
        XCTAssertEqual(UInt32(0xFFFF8000).trailingZeroes, 15)
        XCTAssertEqual(UInt32(0xFFF10000).trailingZeroes, 16)
        XCTAssertEqual(UInt32(0xFFFE0000).trailingZeroes, 17)
        XCTAssertEqual(UInt32(0x00000000).trailingZeroes, 32)
    }

    func testUInt64_trailingZeroes() {
        XCTAssertEqual(UInt64.max.trailingZeroes, 0)
        XCTAssertEqual((0xFFFFFFFF80000000 as UInt64).trailingZeroes, 31)
        XCTAssertEqual((0xFFFFFFF100000000 as UInt64).trailingZeroes, 32)
        XCTAssertEqual((0xFFFFFFFE00000000 as UInt64).trailingZeroes, 33)
        XCTAssertEqual((0x0000000000000000 as UInt64).trailingZeroes, 64)
    }

    func testUInt_trailingZeroes() {
        XCTAssertEqual(UInt.max.trailingZeroes, 0)
        XCTAssertEqual((0xFFFFFFFF80000000 as UInt).trailingZeroes, 31)
        XCTAssertEqual((0xFFFFFFF100000000 as UInt).trailingZeroes, 32)
        XCTAssertEqual((0xFFFFFFFE00000000 as UInt).trailingZeroes, 33)
        XCTAssertEqual((0x0000000000000000 as UInt).trailingZeroes, 64)
    }
}
