//
//  WordTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2017-7-26.
//  Copyright © 2017 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

struct TestDivision<Word: FixedWidthInteger> where Word.Magnitude == Word {
    static func testDivision(_ u: (high: Word, low: Word.Magnitude), _ v: Word) {
        let (div, mod) = v.fastDividingFullWidth(u)
        var (ph, pl) = div.multipliedFullWidth(by: v)
        let (s, o) = pl.addingReportingOverflow(mod)
        pl = s
        if o { ph += Word(1) }

        if mod >= v {
            XCTFail("For u = \(u), v = \(v): u mod v = \(mod), which is greater than v")
        }

        func message() -> String {
            let uhs = String(u.high, radix: 16)
            let uls = String(u.low, radix: 16)
            let vs = String(v, radix: 16)
            let divs = String(div, radix: 16)
            let mods = String(mod, radix: 16)
            let phs = String(ph, radix: 16)
            let pls = String(pl, radix: 16)
            return "(\(uhs),\(uls)) / \(vs) = (\(divs), \(mods)), but div * v + mod = (\(phs),\(pls))"
        }
        XCTAssertEqual(ph, u.high, message())
        XCTAssertEqual(pl, u.low, message())
    }

    static func test() {
        testDivision((0, 0), 2)
        testDivision((0, 1), 2)
        testDivision((1, 0), 2)
        testDivision((8, 0), 136)
        testDivision((128, 0), 136)
        testDivision((2, 0), 35)
        testDivision((7, 12), 19)
    }
}

class FullDivisionTests: XCTestCase {
    func testFullDivide() {
        TestDivision<UInt8>.test()
        TestDivision<UInt16>.test()
        TestDivision<UInt32>.test()
        TestDivision<UInt64>.test()
        TestDivision<UInt>.test()

        #if false
        typealias Word = UInt8
        for v in 1 ... Word.max {
            for u1 in 0 ..< v {
                for u0 in 0 ..< Word.max {
                    TestDivision<Word>.testDivision((u1, u0), v)
                }
            }
        }
        #endif
    }
}
