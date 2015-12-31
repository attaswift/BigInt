//
//  BitwiseTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

class BitwiseTests: XCTestCase {

    func testUInt8_high_low() {
        let n: UInt8 = 0x12
        XCTAssertEqual(n.high, 0x1)
        XCTAssertEqual(n.low, 0x2)
    }

    func testUInt16_high_low() {
        let n: UInt16 = 0x1234
        XCTAssertEqual(n.high, 0x12)
        XCTAssertEqual(n.low, 0x34)
    }
    func testUInt32_high_low() {
        let n: UInt32 = 0x12345678
        XCTAssertEqual(n.high, 0x1234)
        XCTAssertEqual(n.low, 0x5678)
    }
    func testUInt64_high_low() {
        let n: UInt64 = 0x0123456789ABCDEF
        XCTAssertEqual(n.high, 0x01234567)
        XCTAssertEqual(n.low, 0x89ABCDEF)
    }
    func testUInt_high_low() {
        let n: UInt = 0x0123456789ABCDEF
        XCTAssertEqual(n.high, 0x01234567)
        XCTAssertEqual(n.low, 0x89ABCDEF)
    }

    func testUInt8_width() {
        for i in 0...255 {
            let width = UInt8(i).width
            XCTAssertLessThanOrEqual(width, 8)
            XCTAssertGreaterThan(1 << Int(width), i)
            if i > 0 {
                XCTAssertLessThanOrEqual(1 << Int(width - 1), i)
            }
        }
    }

    func testUInt8_mask() {
        for i in 0...255 {
            let num = UInt8(i)
            let mask = num.mask
            XCTAssertEqual(num & mask, num)
            if mask > 0 {
                XCTAssertNotEqual(num & (mask / 2), num)
            }
        }
    }

    func testRankTable() {
        XCTAssertEqual(widthTable.count, 256)
    }

    func testUInt16_width() {
        XCTAssertEqual(UInt16(0x0000).width, 0)
        XCTAssertEqual(UInt16(0x0080).width, 8)
        XCTAssertEqual(UInt16(0x00FF).width, 8)
        XCTAssertEqual(UInt16(0x0100).width, 9)
        XCTAssertEqual(UInt16(0x01FF).width, 9)
        XCTAssertEqual(UInt16(0x0200).width, 10)
        XCTAssertEqual(UInt16(0xFFFF).width, 16)
    }

    func testUInt16_mask() {
        XCTAssertEqual(UInt16(0x0000).mask, 0x0000)
        XCTAssertEqual(UInt16(0x0080).mask, 0x00FF)
        XCTAssertEqual(UInt16(0x00FF).mask, 0x00FF)
        XCTAssertEqual(UInt16(0x0100).mask, 0x01FF)
        XCTAssertEqual(UInt16(0x01FF).mask, 0x01FF)
        XCTAssertEqual(UInt16(0x0200).mask, 0x03FF)
        XCTAssertEqual(UInt16(0xFFFF).mask, 0xFFFF)
    }

    func testUInt32_width() {
        XCTAssertEqual(UInt32(0x00000000).width, 0)
        XCTAssertEqual(UInt32(0x00008000).width, 16)
        XCTAssertEqual(UInt32(0x0000FFFF).width, 16)
        XCTAssertEqual(UInt32(0x00010000).width, 17)
        XCTAssertEqual(UInt32(0x0001FFFF).width, 17)
        XCTAssertEqual(UInt32(0x00020000).width, 18)
        XCTAssertEqual(UInt32(0xFFFFFFFF).width, 32)
    }

    func testUInt32_mask() {
        XCTAssertEqual(UInt32(0x00000000).mask, 0x00000000)
        XCTAssertEqual(UInt32(0x00008000).mask, 0x0000FFFF)
        XCTAssertEqual(UInt32(0x0000FFFF).mask, 0x0000FFFF)
        XCTAssertEqual(UInt32(0x00010000).mask, 0x0001FFFF)
        XCTAssertEqual(UInt32(0x0001FFFF).mask, 0x0001FFFF)
        XCTAssertEqual(UInt32(0x00020000).mask, 0x0003FFFF)
        XCTAssertEqual(UInt32(0xFFFFFFFF).mask, 0xFFFFFFFF)
    }

    func testUInt64_width() {
        XCTAssertEqual(UInt64(0x0000000000000000).width, 0)
        XCTAssertEqual(UInt64(0x0000000080000000).width, 32)
        XCTAssertEqual(UInt64(0x00000000FFFFFFFF).width, 32)
        XCTAssertEqual(UInt64(0x0000000100000000).width, 33)
        XCTAssertEqual(UInt64(0x00000001FFFFFFFF).width, 33)
        XCTAssertEqual(UInt64(0x0000000200000000).width, 34)
        XCTAssertEqual(UInt64.max.width, 64)
    }

    func testUInt64_mask() {
        XCTAssertEqual(UInt64(0x0000000000000000).mask, 0x0000000000000000)
        XCTAssertEqual(UInt64(0x0000000080000000).mask, 0x00000000FFFFFFFF)
        XCTAssertEqual(UInt64(0x00000000FFFFFFFF).mask, 0x00000000FFFFFFFF)
        XCTAssertEqual(UInt64(0x0000000100000000).mask, 0x00000001FFFFFFFF)
        XCTAssertEqual(UInt64(0x00000001FFFFFFFF).mask, 0x00000001FFFFFFFF)
        XCTAssertEqual(UInt64(0x0000000200000000).mask, 0x00000003FFFFFFFF)
        XCTAssertEqual(UInt64.max.mask, UInt64.max)
    }

    func testUInt_width() {
        XCTAssertEqual(UInt(0x0000000000000000).width, 0)
        XCTAssertEqual(UInt(0x0000000080000000).width, 32)
        XCTAssertEqual(UInt(0x00000000FFFFFFFF).width, 32)
        XCTAssertEqual(UInt(0x0000000100000000).width, 33)
        XCTAssertEqual(UInt(0x00000001FFFFFFFF).width, 33)
        XCTAssertEqual(UInt(0x0000000200000000).width, 34)
        XCTAssertEqual(UInt.max.width, 64)
    }

    func testUInt_mask() {
        XCTAssertEqual(UInt(0x0000000000000000).mask, 0x0000000000000000)
        XCTAssertEqual(UInt(0x0000000080000000).mask, 0x00000000FFFFFFFF)
        XCTAssertEqual(UInt(0x00000000FFFFFFFF).mask, 0x00000000FFFFFFFF)
        XCTAssertEqual(UInt(0x0000000100000000).mask, 0x00000001FFFFFFFF)
        XCTAssertEqual(UInt(0x00000001FFFFFFFF).mask, 0x00000001FFFFFFFF)
        XCTAssertEqual(UInt(0x0000000200000000).mask, 0x00000003FFFFFFFF)
        XCTAssertEqual(UInt.max.mask, UInt.max)
    }

}
