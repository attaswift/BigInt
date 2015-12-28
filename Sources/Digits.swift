//
//  Digits.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

#if TinyDigits
public typealias Digit = UInt8
#else
public typealias Digit = UIntMax
#endif

//MARK: Digit multiplication

extension Digit {
    internal static func fullMultiply(x: Digit, _ y: Digit) -> (high: Digit, low: Digit) {
        let a = Digit(x.high)
        let b = Digit(x.low)
        let c = Digit(y.high)
        let d = Digit(y.low)

        // We don't have a full-width multiplication, so we build it out of half-width multiplications.
        // x * y = ac * HH + (ad + bc) * H + bd where H = 2^(n/2)
        let (mv, mo) = Digit.addWithOverflow(a * d, b * c)
        let (low, lo) = Digit.addWithOverflow(b * d, Digit(mv.low) << Digit.halfShift)
        let high = a * c + Digit(mv.high) + (mo ? 1 << Digit.halfShift : 0) + (lo ? 1 : 0)
        return (high, low)
    }
}

extension Array where Element: UnsignedIntegerType {
    mutating func shrink() {
        while last == Element(0) {
            removeLast()
        }
    }
}
