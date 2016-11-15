//
//  Bitwise Hacks.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2016 Károly Lőrentey.
//

/// For all `i` less than 256, `leadingZeroesTable[i]` is the number of leading zero bits in `i`'s 8-bit representation.
/// I.e., the minimum number of bits necessary to represent `i` is `8 - leadingZeroes[i]`.
internal let leadingZeroesTable: [UInt8] = [
    8,
    7,
    6, 6,
    5, 5, 5, 5,
    4, 4, 4, 4, 4, 4, 4, 4,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
]
/// For all `i` less than 256, `trailingZeroesTable[i]` is the number of trailing zero bits in `i`'s 8-bit representation.
internal let trailingZeroesTable: [UInt8] = [
    /*0*/ 8, 0,
    /*1*/ 1, 0,
    /*2*/ 2, 0, /*1*/ 1, 0,
    /*3*/ 3, 0, /*1*/ 1, 0,
                /*2*/ 2, 0, 1, 0,
    /*4*/ 4, 0, /*1*/ 1, 0,
                /*2*/ 2, 0, 1, 0,
                /*3*/ 3, 0, 1, 0, 2, 0, 1, 0,
    /*5*/ 5, 0, /*1*/ 1, 0,
                /*2*/ 2, 0, 1, 0,
                /*3*/ 3, 0, 1, 0, 2, 0, 1, 0,
                /*4*/ 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
    /*6*/ 6, 0, /*1*/ 1, 0,
                /*2*/ 2, 0, 1, 0,
                /*3*/ 3, 0, 1, 0, 2, 0, 1, 0,
                /*4*/ 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
                /*5*/ 5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,

    /*7*/ 7, 0, /*1*/ 1, 0,
                /*2*/ 2, 0, 1, 0,
                /*3*/ 3, 0, 1, 0, 2, 0, 1, 0,
                /*4*/ 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
                /*5*/ 5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
                /*6*/ 6, 0, 1, 0,
                            2, 0, 1, 0,
                            3, 0, 1, 0, 2, 0, 1, 0,
                            4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
                            5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
]

extension UInt8 {
    internal static var width: Int { return 8 }

    internal var low: UInt8 { return self & 0xF }
    internal var high: UInt8 { return self >> 4 }
    internal var split: (high: UInt8, low: UInt8) { return (high, low) }

    internal var leadingZeroes: Int { return Int(leadingZeroesTable[Int(self)]) }
    internal var trailingZeroes: Int { return Int(trailingZeroesTable[Int(self)]) }
}
extension UInt16 {
    internal static var width: Int { return 16 }

    internal var low: UInt16 { return self & 0xFF }
    internal var high: UInt16 { return self >> 8 }
    internal var split: (high: UInt16, low: UInt16) { return (high, low) }

    internal var leadingZeroes: Int { return high == 0 ? 8 + UInt8(low).leadingZeroes : UInt8(high).leadingZeroes }
    internal var trailingZeroes: Int { return low == 0 ? 8 + UInt8(high).trailingZeroes : UInt8(low).trailingZeroes }
}
extension UInt32 {
    internal static var width: Int { return 32 }

    internal var low: UInt32 { return self & 0xFFFF }
    internal var high: UInt32 { return self >> 16 }
    internal var split: (high: UInt32, low: UInt32) { return (high, low) }

    internal var leadingZeroes: Int { return high == 0 ? 16 + UInt16(low).leadingZeroes : UInt16(high).leadingZeroes }
    internal var trailingZeroes: Int { return low == 0 ? 16 + UInt16(high).trailingZeroes : UInt16(low).trailingZeroes }
}
extension UInt64 {
    internal static var width: Int { return 64 }

    internal var low: UInt64 { return self & 0xFFFFFFFF }
    internal var high: UInt64 { return self >> 32 }
    internal var split: (high: UInt64, low: UInt64) { return (high, low) }

    internal var leadingZeroes: Int { return high == 0 ? 32 + UInt32(low).leadingZeroes : UInt32(high).leadingZeroes }
    internal var trailingZeroes: Int { return low == 0 ? 32 + UInt32(high).trailingZeroes : UInt32(low).trailingZeroes }
}

extension UInt {
    internal var low: UInt {
        precondition(MemoryLayout<UInt>.size == 8)
        return self & 0xFFFFFFFF
    }
    internal var high: UInt {
        precondition(MemoryLayout<UInt>.size == 8)
        return self >> 32
    }
    internal var split: (high: UInt, low: UInt) { return (high, low) }
    internal static let halfShift: UInt = 32

    internal var leadingZeroes: Int { return high == 0 ? 32 + UInt32(low).leadingZeroes : UInt32(high).leadingZeroes }
    internal var trailingZeroes: Int { return low == 0 ? 32 + UInt32(high).trailingZeroes : UInt32(low).trailingZeroes }
}
