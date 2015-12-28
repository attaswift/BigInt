//
//  Bitwise Hacks.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

/// For all `i` less than 256, `rankTable[i]` is the number of bits necessary to store the binary representation of `i`.
internal let rankTable: [Int8] = [
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
    var low: UInt8 { return UInt8(self & 0xF) }
    var high: UInt8 { return UInt8(self >> 4) }
    static let halfShift: UInt8 = 4

    var rank: Int { return Int(rankTable[Int(self)]) }
    var mask: UInt8 {
        if rank == 8 { return .max }
        return (1 << UInt8(rank)) - 1
    }
}
extension UInt16 {
    var low: UInt8 { return UInt8(self & 0xFF) }
    var high: UInt8 { return UInt8(self >> 8) }
    static let halfShift: UInt16 = 8

    var rank: Int { return high == 0 ? low.rank : high.rank + 8 }
    var mask: UInt16 {
        if rank == 16 { return .max }
        return (1 << UInt16(rank)) - 1
    }
}
extension UInt32 {
    var low: UInt16 { return UInt16(self & 0xFFFF) }
    var high: UInt16 { return UInt16(self >> 16) }
    static let halfShift: UInt32 = 16

    var rank: Int { return high == 0 ? low.rank : high.rank + 16 }
    var mask: UInt32 {
        if rank == 32 { return .max }
        return (1 << UInt32(rank)) - 1
    }
}
extension UInt64 {
    var low: UInt32 { return UInt32(self & 0xFFFFFFFF) }
    var high: UInt32 { return UInt32(self >> 32) }
    static let halfShift: UInt64 = 32

    var rank: Int { return high == 0 ? low.rank : high.rank + 32 }
    var mask: UInt64 {
        if rank == 64 { return .max }
        return (1 << UInt64(rank)) - 1
    }
}

extension UInt {
    var low: UInt32 {
        precondition(sizeof(UInt) == 8)
        return UInt32(self & 0xFFFFFFFF)
    }
    var high: UInt32 {
        precondition(sizeof(UInt) == 8)
        return UInt32(self >> 32)
    }
    static let halfShift: UInt = 32

    var rank: Int {
        precondition(sizeof(UInt) == 8)
        return high == 0 ? low.rank : high.rank + 32
    }
    var mask: UInt {
        precondition(sizeof(UInt) == 8)
        if rank == 64 { return .max }
        return (1 << UInt(rank)) - 1
    }
}