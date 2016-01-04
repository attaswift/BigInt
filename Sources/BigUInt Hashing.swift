//
//  BigUInt Hashing.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

extension BigUInt: Hashable {
    //MARK: Hashing

    /// The hash value.
    public var hashValue: Int {
        var hash: UInt64 = UInt64(count).byteSwapped
        for i in 0..<count {
            let shift: UInt64 = ((UInt64(i) << 5) - UInt64(i)) & 63
            let rotated = (hash >> shift) | ((hash & ((1 << shift) - 1)) << shift)
            hash = rotated ^ UInt64(UInt(truncatingBitPattern: Int64(self[i].hashValue &+ i)))
        }

        return Int(truncatingBitPattern: hash)
    }
}
