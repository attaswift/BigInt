//
//  BigUInt Bitwise Ops.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

extension BigUInt: BitwiseOperations {
    //MARK: Bitwise Operations

    /// The empty bitset.
    public static let allZeros: BigUInt = 0

    /// The minimum number of bits required to represent this integer in binary.
    ///
    /// - Returns: floor(log2(2 * self + 1))
    /// - Complexity: O(1)
    public var width: Int {
        guard count > 0 else { return 0 }
        return count * Digit.width - self[count - 1].leadingZeroes
    }

    /// The number of leading zero bits in the binary representation of this integer in base `2^Digit.width`.
    /// This is useful when you need to normalize a `BigUInt` such that the top bit of its most significant digit is 1.
    ///
    /// - Note: 0 is considered to have zero leading zero bits.
    /// - Returns: A value in `0...(Digit.width - 1)`.
    /// - SeeAlso: width
    /// - Complexity: O(1)
    public var leadingZeroes: Int {
        guard count > 0 else { return 0 }
        return self[count - 1].leadingZeroes
    }

    /// The number of trailing zero bits in the binary representation of this integer.
    ///
    /// - Note: 0 is considered to have zero trailing zero bits.
    /// - Returns: A value in `0...width`.
    /// - Complexity: O(count)
    public var trailingZeroes: Int {
        guard count > 0 else { return 0 }
        let i = self.index { $0 != 0 }!
        return i * Digit.width + self[i].trailingZeroes
    }

    /// Return the ones' complement of `a`.
    ///
    /// - Complexity: O(a.count)
    public static prefix func ~(a: BigUInt) -> BigUInt {
        return BigUInt(a.map { ~$0 })
    }

    /// Calculate the bitwise OR of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func | (a: BigUInt, b: BigUInt) -> BigUInt {
        var result = BigUInt()
        for i in (0 ..< Swift.max(a.count, b.count)).reversed() {
            result[i] = a[i] | b[i]
        }
        return result
    }

    /// Calculate the bitwise AND of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func & (a: BigUInt, b: BigUInt) -> BigUInt {
        var result = BigUInt()
        for i in (0 ..< Swift.max(a.count, b.count)).reversed() {
            result[i] = a[i] & b[i]
        }
        return result
    }

    /// Calculate the bitwise OR of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func ^ (a: BigUInt, b: BigUInt) -> BigUInt {
        var result = BigUInt()
        for i in (0 ..< Swift.max(a.count, b.count)).reversed() {
            result[i] = a[i] ^ b[i]
        }
        return result
    }

    /// Calculate the bitwise OR of `a` and `b`, and store the result in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func |= (a: inout BigUInt, b: BigUInt) {
        a = a | b
    }

    /// Calculate the bitwise AND of `a` and `b`, and store the result in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func &= (a: inout BigUInt, b: BigUInt) {
        a = a & b
    }
    
    /// Calculate the bitwise XOR of `a` and `b`, and store the result in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func ^= (a: inout BigUInt, b: BigUInt) {
        a = a ^ b
    }
}
