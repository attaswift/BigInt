//
//  ProfileTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-31.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import XCTest
import BigInt

#if Profile

func randomBigInt(digits: Int) -> BigUInt {
    let p = UnsafeMutablePointer<UInt64>.alloc(digits)
    arc4random_buf(p, digits * sizeof(UInt64))

    var result: BigUInt = 0
    for i in 0 ..< digits {
        result[i] = p[i]
    }
    p.destroy()
    return result
}

func randomArray(digits: Int) -> [UInt32] {
    let p = UnsafeMutablePointer<UInt32>.alloc(digits)
    arc4random_buf(p, digits * sizeof(UInt32))

    var result: [UInt32] = []
    for i in 0 ..< digits {
        result.append(p[i])
    }
    p.destroy()
    return result
}

class ProfileTests: XCTestCase {
    typealias Digit = BigUInt.Digit

    func measure(autostart autostart: Bool = true, block: Void->Void) {
        var round = 0
        self.measureMetrics(self.dynamicType.defaultPerformanceMetrics(), automaticallyStartMeasuring: autostart) {
            print("Round \(round) started")
            block()
            round += 1
        }
    }

    func testFibonacciAddition() {
        var n1 = BigUInt(1)
        var n2 = BigUInt(1)
        self.measure {
            n1 = BigUInt(1)
            n2 = BigUInt(1)
            for i in 0..<200000 {
                if i & 1 == 0 {
                    n1 += n2
                }
                else {
                    n2 += n1
                }
            }
        }
        print(n1, n2)
    }

    func checkFactorial(fact: BigUInt, n: Int, file: String = __FILE__, line: UInt = __LINE__) {
        var remaining = fact
        for i in 1...n {
            let (div, mod) = remaining.divide(BigUInt(i))
            XCTAssertEqual(mod, 0, "for divisor = \(i)", file: file, line: line)
            remaining = div
        }
        XCTAssertEqual(remaining, 1, file: file, line: line)
    }

    func testMultiplicationByDigit() {
        var fact = BigUInt()
        let n = 32767
        self.measure {
            fact = BigUInt(1)
            for i in 1...n {
                fact.multiplyInPlaceByDigit(Digit(i))
            }
        }
        checkFactorial(fact, n: n)
    }

    func testBalancedMultiplication() {
        func balancedFactorial(level level: Int, offset: Int = 0) -> BigUInt {
            if level == 0 {
                return BigUInt(offset == 0 ? 1 : offset)
            }
            let a = balancedFactorial(level: level - 1, offset: 2 * offset)
            let b = balancedFactorial(level: level - 1, offset: 2 * offset + 1)
            return a * b
        }

        let power = 15

        var fact = BigUInt()
        self.measure {
            fact = balancedFactorial(level: power)
        }
        checkFactorial(fact, n: 1 << power - 1)
    }

    func testDivision() {
        var divisors: [BigUInt] = []
        func balancedFactorial(level level: Int, offset: Int = 0) -> BigUInt {
            if level == 0 {
                return BigUInt(offset == 0 ? 1 : offset)
            }
            let a = balancedFactorial(level: level - 1, offset: 2 * offset)
            let b = balancedFactorial(level: level - 1, offset: 2 * offset + 1)
            let p = a * b
            if level >= 10 { divisors.append(p) }
            return p
        }

        let power = 14

        let fact = balancedFactorial(level: power)
        print("Performing \(divisors.count) divisions with digit counts (\(fact.count) / (\(divisors[0].count)...\(divisors[divisors.count - 1].count))")
        var divs: [BigUInt] = []
        var mods: [BigUInt] = []
        divs.reserveCapacity(divisors.count)
        mods.reserveCapacity(divisors.count)
        self.measure(autostart: false) {
            divs.removeAll()
            mods.removeAll()
            self.startMeasuring()
            for divisor in divisors {
                let (div, mod) = fact.divide(divisor)
                divs.append(div)
                mods.append(mod)
            }
            self.stopMeasuring()
        }
        for i in 0..<mods.count {
            XCTAssertEqual(mods[i], 0, "div = \(divs[i]), mod = \(mods[i]) for divisor = \(divisors[i])")
        }
        checkFactorial(fact, n: 1 << power - 1)
    }

    func testSquareRoot() {
        var numbers: [BigUInt] = (1...1000).map { _ in randomBigInt(60) }
        var roots: [BigUInt] = []
        self.measure {
            roots.removeAll()
            for number in numbers {
                let root = sqrt(number)
                roots.append(root)
            }
        }

        for i in 0..<numbers.count {
            XCTAssertLessThanOrEqual(roots[i] * roots[i], numbers[i])
            XCTAssertGreaterThan((roots[i] + 1) * (roots[i] + 1), numbers[i])
        }
    }

    func testModularExponentiation() {
        let m15 = (BigUInt(1) << 1279) - 1

        let tests = (1..<25).map { _ in randomBigInt(1279 / (8 * sizeof(Digit))) }
        self.measure {
            for test in tests {
                assert(test < m15)
                let x = BigUInt.powmod(test, m15, modulus: m15)
                XCTAssertEqual(x, test)
            }
        }
    }

    func testGCD() {
        var fibo: [BigUInt] = [0, 1]
        for i in 0..<99998 {
            fibo.append(fibo[i] + fibo[i + 1])
        }

        self.measure {
            for _ in 0..<10 {
                let i = Int(50000 + arc4random_uniform(50000))
                let j = Int(50000 + arc4random_uniform(50000))
                let bi = BigUInt(i)
                let bj = BigUInt(j)

                let g1 = BigUInt.gcd(fibo[i], fibo[j])
                let g2 = Int(BigUInt.gcd(bi, bj)[0])
                XCTAssertEqual(g1, fibo[g2])
            }
        }
    }
}
#endif
