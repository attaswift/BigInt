//
//  BigInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

//MARK: BigInt

/// An arbitary precision signed integer type, also known as a "big integer".
///
/// Operations on big integers never overflow, but they might take a long time to execute.
/// The amount of memory (and address space) available is the only constraint to the magnitude of these numbers.
///
/// This particular big integer type uses base-2^64 digits to represent integers.
///
/// `BigInt` is essentially a tiny wrapper that extends `BigUInt` with a sign bit and provides signed integer
/// operations. Both the underlying absolute value and the negative/positive flag are available as read-write 
/// properties.
///
/// Not all algorithms of `BigUInt` are available for `BigInt` values; for example, there is no square root or
/// primality test for signed integers. When you need to call one of these, just extract the absolute value:
///
/// ```Swift
/// BigInt(255).abs.isPrime()   // Returns false
/// ```
///
public struct BigInt {
    /// The absolute value of this integer.
    public var abs: BigUInt
    /// True iff the value of this integer is negative.
    public var negative: Bool

    /// Initializes a new big integer with the provided absolute number and sign flag.
    public init(abs: BigUInt, negative: Bool = false) {
        self.abs = abs
        self.negative = (abs.isZero ? false : negative)
    }

    /// Initializes a new big integer with the same value as the specified integer.
    public init<I: UnsignedIntegerType>(_ integer: I) {
        self.init(abs: BigUInt(integer), negative: false)
    }

    /// Initializes a new big integer with the same value as the specified integer.
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

    /// Initializes a new signed big integer with the same value as the specified unsigned big integer.
    public init(_ integer: BigUInt) {
        self.abs = integer
        self.negative = false
    }
}

extension BigInt {
    /// Initialize a big integer from an ASCII representation in a given radix. Numerals above `9` are represented by
    /// letters from the English alphabet.
    ///
    /// - Requires: `radix > 1 && radix < 36`
    /// - Parameter `text`: A string optionally starting with "-" or "+" followed by characters corresponding to numerals in the given radix. (0-9, a-z, A-Z)
    /// - Parameter `radix`: The base of the number system to use, or 10 if unspecified.
    /// - Returns: The integer represented by `text`, or nil if `text` contains a character that does not represent a numeral in `radix`.
    public init?(_ text: String, radix: Int = 10) {
        var text = text
        var negative = false
        if text.characters.first == "-" {
            negative = true
            text = text.substringFromIndex(text.startIndex.successor())
        }
        else if text.characters.first == "+" {
            text = text.substringFromIndex(text.startIndex.successor())
        }
        guard let abs = BigUInt(text, radix: radix) else { return nil }
        self.abs = abs
        self.negative = negative
    }
}

extension String {
    /// Initialize a new string representing a signed big integer in the given radix (base).
    ///
    /// Numerals greater than 9 are represented as letters from the English alphabet,
    /// starting with `a` if `uppercase` is false or `A` otherwise.
    ///
    /// - Requires: radix > 1 && radix <= 36
    /// - Complexity: O(count) when radix is a power of two; otherwise O(count^2).
    public init(_ value: BigInt, radix: Int = 10, uppercase: Bool = false) {
        self = String(value.abs, radix: radix, uppercase: uppercase)
        if value.negative {
            self = "-" + self
        }
    }
}

extension BigInt: CustomStringConvertible {
    /// Return the decimal representation of this integer.
    public var description: String { return String(self, radix: 10) }
}

extension BigInt: IntegerLiteralConvertible {

    /// Initialize a new big integer from an integer literal.
    public init(integerLiteral value: IntMax) {
        self.init(value)
    }
}

extension BigInt: StringLiteralConvertible {
    /// Initialize a new big integer from a Unicode scalar.
    /// The scalar must represent a decimal digit.
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = BigInt(String(value), radix: 10)!
    }

    /// Initialize a new big integer from an extended grapheme cluster.
    /// The cluster must consist of a decimal digit.
    public init(extendedGraphemeClusterLiteral value: String) {
        self = BigInt(value, radix: 10)!
    }

    /// Initialize a new big integer from a decimal number represented by a string literal of arbitrary length.
    /// The string must contain only decimal digits.
    public init(stringLiteral value: StringLiteralType) {
        self = BigInt(value, radix: 10)!
    }
}

extension BigInt: CustomPlaygroundQuickLookable {
    /// Return the playground quick look representation of this integer.
    @warn_unused_result
    public func customPlaygroundQuickLook() -> PlaygroundQuickLook {
        let text = String(self)
        return PlaygroundQuickLook.Text(text + " (\(self.abs.width) bits)")
    }
}

extension BigInt: Comparable {
}

/// Return true iff `a` is equal to `b`.
@warn_unused_result
public func ==(a: BigInt, b: BigInt) -> Bool {
    return a.negative == b.negative && a.abs == b.abs
}

/// Return true iff `a` is less than `b`.
@warn_unused_result
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
    /// Return the hash value of this integer.
    public var hashValue: Int {
        let v = abs.hashValue
        return negative ? ~v : v
    }
}

/// Add `a` to `b` and return the result.
@warn_unused_result
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

/// Negate `a` and return the result.
@warn_unused_result
public prefix func -(a: BigInt) -> BigInt {
    if a.abs.isZero { return a }
    return BigInt(abs: a.abs, negative: !a.negative)
}

/// Subtract `b` from `a` and return the result.
@warn_unused_result
public func -(a: BigInt, b: BigInt) -> BigInt {
    return a + (-b)
}

/// Multiply `a` with `b` and return the result.
@warn_unused_result
public func *(a: BigInt, b: BigInt) -> BigInt {
    return BigInt(abs: a.abs * b.abs, negative: a.negative != b.negative)
}

/// Divide `a` by `b` and return the quotient.
@warn_unused_result
public func /(a: BigInt, b: BigInt) -> BigInt {
    return BigInt(abs: a.abs / b.abs, negative: a.negative != b.negative)
}

/// Divide `a` by `b` and return the remainder.
@warn_unused_result
public func %(a: BigInt, b: BigInt) -> BigInt {
    return BigInt(abs: a.abs % b.abs, negative: a.negative)
}

/// Add `b` to `a` in place.
public func +=(inout a: BigInt, b: BigInt) { a = a + b }
/// Subtract `b` from `a` in place.
public func -=(inout a: BigInt, b: BigInt) { a = a - b }
/// Multiply `a` with `b` in place.
public func *=(inout a: BigInt, b: BigInt) { a = a * b }
/// Divide `a` by `b` storing the quotient in `a`.
public func /=(inout a: BigInt, b: BigInt) { a = a / b }
/// Divide `a` by `b` storing the remainder in `a`.
public func %=(inout a: BigInt, b: BigInt) { a = a % b }
