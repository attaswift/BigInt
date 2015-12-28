//
//  BigInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

public struct BigInt {
    public var abs: BigUInt
    public var negative: Bool

    public init(abs: BigUInt, negative: Bool = false) {
        self.abs = abs
        self.negative = (abs.isZero ? false : negative)
    }

    public init(_ value: IntMax) {
        if value == IntMax.min {
            self.negative = true
            self.abs = BigUInt(UIntMax(IntMax.max)) + 1
        }
        else if value < 0 {
            self.negative = true
            self.abs = BigUInt(UIntMax(-value))
        }
        else {
            self.negative = false
            self.abs = BigUInt(UIntMax(value))
        }
    }

}
extension BigInt: IntegerLiteralConvertible {
    public init(integerLiteral value: IntMax) {
        self.init(value)
    }
}

extension BigInt: Comparable {
}
public func ==(a: BigInt, b: BigInt) -> Bool {
    return a.negative == b.negative && a.abs == b.abs
}
public func <(a: BigInt, b: BigInt) -> Bool {
    switch (a.negative, b.negative) {
    case (false, false):
        return a.abs < b.abs
    case (false, true):
        return false
    case (true, false):
        return true
    case (true, true):
        return a.abs > b.abs
    }
}


public func +(a: BigInt, b: BigInt) -> BigInt {
    switch (a.negative, b.negative) {
    case (false, false):
        return BigInt(abs: a.abs + b.abs, negative: false)
    case (true, true):
        return BigInt(abs: a.abs + b.abs, negative: true)
    case (false, true):
        if a.abs >= b.abs {
            return BigInt(abs: a.abs - b.abs, negative: false)
        }
        else {
            return BigInt(abs: b.abs - a.abs, negative: true)
        }
    case (true, false):
        if b.abs >= a.abs {
            return BigInt(abs: b.abs - a.abs, negative: false)
        }
        else {
            return BigInt(abs: a.abs - b.abs, negative: true)
        }
    }
}

public prefix func -(a: BigInt) -> BigInt {
    if a.abs.isZero { return a }
    return BigInt(abs: a.abs, negative: !a.negative)
}

public func -(a: BigInt, b: BigInt) -> BigInt {
    return a + (-b)
}

