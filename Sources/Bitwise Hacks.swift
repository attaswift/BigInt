//
//  Bitwise Hacks.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

/// For all `i` less than 256, `rankTable[i]` is the number of bits necessary to store the binary representation of `i`.
internal let rankTable: [UInt8] = [
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
    var low: UInt8 { return self & 0xF }
    var high: UInt8 { return self >> 4 }
    var split: (high: UInt8, low: UInt8) { return (high, low) }
    static let halfShift: UInt8 = 4

    var rank: UInt8 { return rankTable[Int(self)] }
    var mask: UInt8 {
        if rank == 8 { return .max }
        return (1 << UInt8(rank)) - 1
    }
}
extension UInt16 {
    var low: UInt16 { return self & 0xFF }
    var high: UInt16 { return self >> 8 }
    var split: (high: UInt16, low: UInt16) { return (high, low) }
    static let halfShift: UInt16 = 8

    var rank: UInt16 {
        let rank = high == 0 ? UInt8(low).rank : UInt8(high).rank + 8
        return UInt16(rank)
    }
    var mask: UInt16 {
        if rank == 16 { return .max }
        return (1 << UInt16(rank)) - 1
    }
}
extension UInt32 {
    var low: UInt32 { return self & 0xFFFF }
    var high: UInt32 { return self >> 16 }
    var split: (high: UInt32, low: UInt32) { return (high, low) }
    static let halfShift: UInt32 = 16

    var rank: UInt32 {
        let rank = high == 0 ? UInt16(low).rank : UInt16(high).rank + 16
        return UInt32(rank)
    }
    var mask: UInt32 {
        if rank == 32 { return .max }
        return (1 << UInt32(rank)) - 1
    }
}
extension UInt64 {
    var low: UInt64 { return self & 0xFFFFFFFF }
    var high: UInt64 { return self >> 32 }
    var split: (high: UInt64, low: UInt64) { return (high, low) }
    static let halfShift: UInt64 = 32

    var rank: UInt64 {
        let rank = high == 0 ? UInt32(low).rank : UInt32(high).rank + 32
        return UInt64(rank)
    }
    var mask: UInt64 {
        if rank == 64 { return .max }
        return (1 << UInt64(rank)) - 1
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

    var rank: UInt {
        precondition(sizeof(UInt) == 8)
        let rank = high == 0 ? UInt64(low).rank : UInt64(high).rank + 32
        return UInt(rank)
    }
    var mask: UInt {
        precondition(sizeof(UInt) == 8)
        if rank == 64 { return .max }
        return (1 << UInt(rank)) - 1
    }
}