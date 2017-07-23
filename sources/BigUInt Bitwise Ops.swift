//
//  BigUInt Bitwise Ops.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016-2017 Károly Lőrentey.
//

extension BigUInt {
    //MARK: Bitwise Operations
    
    /// The minimum number of bits required to represent this integer in binary.
    ///
    /// - Returns: floor(log2(2 * self + 1))
    /// - Complexity: O(1)
    public var bitWidth: Int {
        guard count > 0 else { return 0 }
        return count * Word.bitWidth - self[count - 1].leadingZeroBitCount
    }

    /// The number of leading zero bits in the binary representation of this integer in base `2^(Word.bitWidth)`.
    /// This is useful when you need to normalize a `BigUInt` such that the top bit of its most significant word is 1.
    ///
    /// - Note: 0 is considered to have zero leading zero bits.
    /// - Returns: A value in `0...(Word.bitWidth - 1)`.
    /// - SeeAlso: width
    /// - Complexity: O(1)
    public var leadingZeroBitCount: Int {
        guard count > 0 else { return 0 }
        return self[count - 1].leadingZeroBitCount
    }

    /// The number of trailing zero bits in the binary representation of this integer.
    ///
    /// - Note: 0 is considered to have zero trailing zero bits.
    /// - Returns: A value in `0...width`.
    /// - Complexity: O(count)
    public var trailingZeroBitCount: Int {
        guard count > 0 else { return 0 }
        let i = self.words.index { $0 != 0 }!
        return i * Word.bitWidth + self[i].trailingZeroBitCount
    }

    /// Return the ones' complement of `a`.
    ///
    /// - Complexity: O(a.count)
    public static prefix func ~(a: BigUInt) -> BigUInt {
        return BigUInt(words: a.words.map { ~$0 })
    }

    /// Calculate the bitwise OR of `a` and `b`, and store the result in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func |= (a: inout BigUInt, b: BigUInt) {
        a.reserveCapacity(b.count)
        for i in 0 ..< b.count {
            a[i] |= b[i]
        }
    }

    /// Calculate the bitwise AND of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func &= (a: inout BigUInt, b: BigUInt) {
        for i in 0 ..< Swift.max(a.count, b.count) {
            a[i] &= b[i]
        }
    }

    /// Calculate the bitwise XOR of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func ^= (a: inout BigUInt, b: BigUInt) {
        a.reserveCapacity(b.count)
        for i in 0 ..< b.count {
            a[i] ^= b[i]
        }
    }
}
