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

    public init<I: UnsignedIntegerType>(_ integer: I) {
        self.init(abs: BigUInt(integer), negative: false)
    }

    public init<I: SignedIntegerType>(_ integer: I) {
        let i = integer.toIntMax()
        if i == IntMax.min {
            self.init(abs: BigUInt(IntMax.max) + 1, negative: true)
        }
        else if i < 0 {
            self.init(abs: BigUInt(-i), negative: true)
        }
        else {
            self.init(abs: BigUInt(i), negative: false)
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

extension BigInt: Hashable {
    public var hashValue: Int {
        let v = abs.hashValue
        return negative ? ~v : v
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

public func *(a: BigInt, b: BigInt) -> BigInt {
    return BigInt(abs: a.abs * b.abs, negative: a.negative != b.negative)
}

public func /(a: BigInt, b: BigInt) -> BigInt {
    return BigInt(abs: a.abs / b.abs, negative: a.negative != b.negative)
}

public func %(a: BigInt, b: BigInt) -> BigInt {
    return BigInt(abs: a.abs % b.abs, negative: a.negative)
}

public func +=(inout a: BigInt, b: BigInt) { a = a + b }
public func -=(inout a: BigInt, b: BigInt) { a = a - b }
public func *=(inout a: BigInt, b: BigInt) { a = a * b }
public func /=(inout a: BigInt, b: BigInt) { a = a / b }
public func %=(inout a: BigInt, b: BigInt) { a = a % b }
