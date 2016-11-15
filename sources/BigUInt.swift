//
//  BigUInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016 Károly Lőrentey.
//

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
    public typealias Digit = UIntMax
    
    internal var _digits: [Digit]
    internal var _start: Int
    internal var _end: Int

    internal init(digits: [Digit], start: Int, end: Int) {
        precondition(start >= 0 && start <= end)
        let start = Swift.min(start, digits.count)
        var end = Swift.min(end, digits.count)
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
    public init<I: UnsignedInteger>(_ integer: I) {
        self.init(Digit.digitsFromUIntMax(integer.toUIntMax()))
    }

    /// Initializes a new BigUInt that has the supplied value.
    ///
    /// - Requires: integer >= 0
    public init<I: SignedInteger>(_ integer: I) {
        precondition(integer >= 0)
        self.init(UIntMax(integer.toIntMax()))
    }
}

extension BigUInt: ExpressibleByIntegerLiteral {
    //MARK: Init from Integer literals

    /// Initialize a new big integer from an integer literal.
    public init(integerLiteral value: UInt64) {
        self.init(value.toUIntMax())
    }
}

extension BigUInt: ExpressibleByStringLiteral {
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

extension BigUInt: IntegerArithmetic {
    /// Explicitly convert to `IntMax`, trapping on overflow.
    public func toIntMax() -> IntMax {
        precondition(count <= 1)
        return IntMax(self[0])
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

extension BigUInt: RandomAccessCollection {
    //MARK: Collection

    /// Big integers implement `Collection` to provide access to their big digits, indexed by integers; a zero index refers to the least significant digit.
    public typealias Index = Int
    /// The type representing the number of steps between two indices.
    public typealias IndexDistance = Int
    /// The type representing valid indices for subscripting the collection.
    public typealias Indices = CountableRange<Int>
    /// The type representing the iteration interface for the digits in a big integer.
    public typealias Iterator = DigitIterator<Digit>
    /// Big integers can be contiguous digit subranges of another big integer.
    public typealias SubSequence = BigUInt

    public var indices: Indices { return startIndex ..< endIndex }

    /// The index of the first digit, starting from the least significant. (This is always zero.)
    public var startIndex: Int { return 0 }
    /// The index of the digit after the most significant digit in this integer.
    public var endIndex: Int { return count }
    /// The number of digits in this integer, excluding leading zero digits.
    public var count: Int { return _end - _start }

    /// Return a generator over the digits of this integer, starting at the least significant digit.
    public func makeIterator() -> DigitIterator<Digit> {
        return DigitIterator(digits: _digits, end: _end, index: _start)
    }

    /// Returns the position immediately after the given index.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    /// Returns the position immediately before the given index.
    public func index(before i: Int) -> Int {
        return i - 1
    }

    /// Replaces the given index with its successor.
    public func formIndex(after i: inout Int) {
        i += 1
    }

    /// Replaces the given index with its predecessor.
    public func formIndex(before i: inout Int) {
        i -= 1
    }

    /// Returns an index that is the specified distance from the given index.
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return i + n
    }

    /// Returns an index that is the specified distance from the given index,
    /// unless that distance is beyond a given limiting index.
    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        let r = i + n
        if n >= 0 {
            return r <= limit ? r : nil
        }
        return r >= limit ? r : nil
    }

    /// Returns the number of steps between two indices.
    public func distance(from start: Int, to end: Int) -> Int {
        return end - start
    }


    /// Get or set a digit at a given index.
    ///
    /// - Note: Unlike a normal collection, it is OK for the index to be greater than or equal to `endIndex`.
    ///   The subscripting getter returns zero for indexes beyond the most significant digit.
    ///   Setting these extended digits automatically appends new elements to the underlying digit array.
    /// - Requires: index >= 0
    /// - Complexity: The getter is O(1). The setter is O(1) if the conditions below are true; otherwise it's O(count).
    ///    - The integer's storage is not shared with another integer
    ///    - The integer wasn't created as a slice of another integer
    ///    - `index < count`
    public subscript(index: Int) -> Digit {
        get {
            precondition(index >= 0)
            let i = _start + index
            return (i < Swift.min(_end, _digits.count) ? _digits[i] : 0)
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
    public subscript(bounds: Range<Int>) -> BigUInt {
        get {
            return BigUInt(digits: _digits, start: _start + bounds.lowerBound, end: _start + bounds.upperBound)
        }
    }
}

/// State for iterating through the digits of a big integer.
public struct DigitIterator<Digit>: IteratorProtocol {
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

extension BigUInt: Strideable {
    /// A type that can represent the distance between two values of `BigUInt`.
    public typealias Stride = BigInt

    /// Adds `n` to `self` and returns the result. Traps if the result would be less than zero.
    public func advanced(by n: BigInt) -> BigUInt {
        return n < 0 ? self - n.abs : self + n.abs
    }

    /// Returns the (potentially negative) difference between `self` and `other` as a `BigInt`. Never traps.
    public func distance(to other: BigUInt) -> BigInt {
        return BigInt(other) - BigInt(self)
    }
}

extension BigUInt {
    //MARK: Low and High
    
    /// Split this integer into a high-order and a low-order part.
    ///
    /// - Requires: count > 1
    /// - Returns: `(low, high)` such that 
    ///   - `self == low.add(high, atPosition: middleIndex)`
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

