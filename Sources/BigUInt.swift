//
//  BigUInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

/// An arbitary precision unsigned integer type, also known as a "big integer".
///
/// Operations on big integers never overflow, but they might take a long time to execute.
/// The amount of memory (and address space) available is the only constraint to the magnitude of these numbers.
///
/// This particular big integer type uses base-2^64 digits to represent integers; you can think of it as a wrapper
/// around `Array<UInt64>`. In fact, `BigUInt` implements a mutable collection of its `UInt64` digits, with the
/// digit at index 0 being the least significant.
///
/// To make memory management simple, `BigUInt` allows you to subscript it with out-of-bounds indexes:
/// the subscript getter zero-extends the digit sequence, while the subscript setter automatically extends the
/// underlying storage when necessary:
///
/// ```Swift
/// var number = BigUInt(1)
/// number[42]                // Not an error, returns 0
/// number[23] = 1            // Not an error, number is now 2^1472 + 1.
/// ```
///
/// Note that it is rarely a good idea to use big integers as collections; in the vast majority of cases it is much
/// easier to work with the provided high-level methods and operators rather than with raw big digits.
public struct BigUInt {
    /// The type representing a digit in `BigUInt`'s underlying number system.
    public typealias Digit = UInt64
    
    internal var _digits: [Digit]
    internal var _start: Int
    internal var _end: Int

    internal init(digits: [Digit], start: Int, end: Int) {
        precondition(start >= 0 && start <= end)
        let start = min(start, digits.count)
        var end = min(end, digits.count)
        while end > start && digits[end - 1] == 0 { end -= 1 }
        self._digits = digits
        self._start = start
        self._end = end
    }

    /// Initializes a new BigUInt with value 0.
    public init() {
        self.init([])
    }

    /// Initializes a new BigUInt with the specified digits. The digits are ordered from least to most significant.
    public init(_ digits: [Digit]) {
        self.init(digits: digits, start: 0, end: digits.count)
    }

    /// Initializes a new BigUInt that has the supplied value.
    public init<I: UnsignedIntegerType>(_ integer: I) {
        self.init(Digit.digitsFromUIntMax(integer.toUIntMax()))
    }

    /// Initializes a new BigUInt that has the supplied value.
    ///
    /// - Requires: integer >= 0
    public init<I: SignedIntegerType>(_ integer: I) {
        precondition(integer >= 0)
        self.init(UIntMax(integer.toIntMax()))
    }
}

extension BigUInt: IntegerLiteralConvertible {
    //MARK: Init from Integer literals

    /// Initialize a new big integer from an integer literal.
    public init(integerLiteral value: UInt64) {
        self.init(value.toUIntMax())
    }
}

extension BigUInt: StringLiteralConvertible {
    //MARK: Init from String literals

    /// Initialize a new big integer from a Unicode scalar.
    /// The scalar must represent a decimal digit.
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = BigUInt(String(value), radix: 10)!
    }

    /// Initialize a new big integer from an extended grapheme cluster.
    /// The cluster must consist of a decimal digit.
    public init(extendedGraphemeClusterLiteral value: String) {
        self = BigUInt(value, radix: 10)!
    }

    /// Initialize a new big integer from a decimal number represented by a string literal of arbitrary length.
    /// The string must contain only decimal digits.
    public init(stringLiteral value: StringLiteralType) {
        self = BigUInt(value, radix: 10)!
    }
}

extension BigUInt {
    //MARK: Lift and shrink
    
    /// True iff this integer is not a slice.
    internal var isTop: Bool { return _start == 0 && _end == _digits.count }

    /// Ensures that this integer is not a slice, allocating a new digit array if necessary.
    internal mutating func lift() {
        guard !isTop else { return }
        _digits = Array(self)
        _start = 0
        _end = _digits.count
    }

    /// Gets rid of leading zero digits in the digit array.
    internal mutating func shrink() {
        assert(isTop)
        while _digits.last == 0 {
            _digits.removeLast()
        }
        _end = _digits.count
    }
}

extension BigUInt: CollectionType {
    //MARK: CollectionType
    
    /// The number of digits in this integer, excluding leading zero digits.
    public var count: Int { return _end - _start }
    /// The index of the first digit, starting from the least significant. (This is always zero.)
    public var startIndex: Int { return 0 }
    /// The index of the digit after the most significant digit in this integer.
    public var endIndex: Int { return count }

    /// Return a generator over the digits of this integer, starting at the least significant digit.
    public func generate() -> DigitGenerator<Digit> {
        return DigitGenerator(digits: _digits, end: _end, index: _start)
    }

    /// Get or set a digit at a given position.
    ///
    /// - Note: Unlike a normal collection, it is OK for the index to be greater than or equal to `count`.
    ///   The subscripting getter returns zero for indexes beyond the most significant digit.
    ///   Setting these digits automatically appends new elements to the underlying digit array.
    /// - Requires: index >= 0
    /// - Complexity: The getter is O(1). The setter is O(1) if the conditions below are true; otherwise it's O(count).
    ///    - The integer's storage is not shared with another integer
    ///    - The integer wasn't created as a slice of another integer
    ///    - `index < count`
    public subscript(index: Int) -> Digit {
        get {
            precondition(index >= 0)
            let i = _start + index
            return (i < min(_end, _digits.count) ? _digits[i] : 0)
        }
        set(digit) {
            precondition(index >= 0)
            lift()
            let i = _start + index
            if i < _end {
                _digits[i] = digit
                if digit == 0 && i == _end - 1 {
                    shrink()
                }
            }
            else {
                guard digit != 0 else { return }
                while _digits.count < i { _digits.append(0) }
                _digits.append(digit)
                _end = i + 1
            }
        }
    }

    /// Returns an integer built from the digits of this integer in the given range.
    public subscript(range: Range<Int>) -> BigUInt {
        get {
            return BigUInt(digits: _digits, start: _start + range.startIndex, end: _start + range.endIndex)
        }
    }
}

/// The digit generator for a big integer.
public struct DigitGenerator<Digit>: GeneratorType {
    internal let digits: [Digit]
    internal let end: Int
    internal var index: Int

    /// Return the next digit in the integer, or nil if there are no more digits.
    /// Returned digits range from least to most significant.
    public mutating func next() -> Digit? {
        guard index < end else { return nil }
        let v = digits[index]
        index += 1
        return v
    }
}

extension BigUInt {
    //MARK: Low and High
    
    /// Split this integer into a high-order and a low-order part.
    ///
    /// - Requires: count > 1
    /// - Returns: `(low, high)` such that 
    ///   - `self == low.add(high, shift: middleIndex)`
    ///   - `high.width <= floor(width / 2)`
    ///   - `low.width <= ceil(width / 2)`
    /// - Complexity: Typically O(1), but O(count) in the worst case, because high-order zero digits need to be removed after the split.
    internal var split: (high: BigUInt, low: BigUInt) {
        precondition(count > 1)
        let mid = middleIndex
        return (self[mid ..< count], self[0 ..< mid])
    }

    /// Index of the digit at the middle of this integer.
    ///
    /// - Returns: The index of the digit that is least significant in `self.high`.
    internal var middleIndex: Int {
        return (count + 1) / 2
    }

    /// The low-order half of this BigUInt.
    ///
    /// - Returns: `self[0 ..< middleIndex]`
    /// - Requires: count > 1
    internal var low: BigUInt {
        return self[0 ..< middleIndex]
    }

    /// The high-order half of this BigUInt.
    ///
    /// - Returns: `self[middleIndex ..< count]`
    /// - Requires: count > 1
    internal var high: BigUInt {
        return self[middleIndex ..< count]
    }
}

