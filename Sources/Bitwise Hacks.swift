//
//  Bitwise Hacks.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

/// For all `i` less than 256, `widthTable[i]` is the number of bits necessary to store the binary representation of `i`.
internal let widthTable: [UInt8] = [
    0,
    1,
    2, 2,
    3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
]

extension UInt8 {
    public var low: UInt8 { return self & 0xF }
    public var high: UInt8 { return self >> 4 }
    public var split: (high: UInt8, low: UInt8) { return (high, low) }

    public var width: Int { return Int(widthTable[Int(self)]) }
    var mask: UInt8 {
        if width == 8 { return .max }
        return (1 << UInt8(width)) - 1
    }
}
extension UInt16 {
    var low: UInt16 { return self & 0xFF }
    var high: UInt16 { return self >> 8 }
    var split: (high: UInt16, low: UInt16) { return (high, low) }

    var width: Int {
        return high == 0 ? UInt8(low).width : UInt8(high).width + 8
    }
    var mask: UInt16 {
        if width == 16 { return .max }
        return (1 << UInt16(width)) - 1
    }
}
extension UInt32 {
    public var low: UInt32 { return self & 0xFFFF }
    public var high: UInt32 { return self >> 16 }
    public var split: (high: UInt32, low: UInt32) { return (high, low) }

    public var width: Int {
        return high == 0 ? UInt16(low).width : UInt16(high).width + 16
    }
    var mask: UInt32 {
        if width == 32 { return .max }
        return (1 << UInt32(width)) - 1
    }
}
extension UInt64 {
    public var low: UInt64 { return self & 0xFFFFFFFF }
    public var high: UInt64 { return self >> 32 }
    public var split: (high: UInt64, low: UInt64) { return (high, low) }

    public var width: Int {
        return high == 0 ? UInt32(low).width : UInt32(high).width + 32
    }
    var mask: UInt64 {
        if width == 64 { return .max }
        return (1 << UInt64(width)) - 1
    }
}

extension UInt {
    var low: UInt {
        precondition(sizeof(UInt) == 8)
        return self & 0xFFFFFFFF
    }
    var high: UInt {
        precondition(sizeof(UInt) == 8)
        return self >> 32
    }
    var split: (high: UInt, low: UInt) { return (high, low) }
    static let halfShift: UInt = 32

    var width: Int {
        precondition(sizeof(UInt) == 8)
        return high == 0 ? UInt32(low).width : UInt32(high).width + 32
    }
    var mask: UInt {
        precondition(sizeof(UInt) == 8)
        if width == 64 { return .max }
        return (1 << UInt(width)) - 1
    }
}