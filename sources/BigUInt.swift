//
//  BigUInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016-2017 Károly Lőrentey.
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
    public typealias Word = UInt
    public typealias Words = [Word]
    
    public internal(set) var words: [Word]
    
    /// Initializes a new BigUInt with the specified digits. The digits are ordered from least to most significant.
    internal init(words: [Word]) {
        self.words = words
        shrink()
    }
    
    internal init<Words: Collection>(words: Words) where Words.Element == Word {
        self.words = Array(words)
        shrink()
    }
    

    /// Initializes a new BigUInt with value 0.
    public init() {
        self.init(words: [])
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        words.reserveCapacity(minimumCapacity)
    }
}

extension BigUInt: ExpressibleByIntegerLiteral {
    //MARK: Init from Integer literals
    
    /// Initialize a new big integer from an integer literal.
    public init(integerLiteral value: UInt64) {
        self.init(value)
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

extension BigUInt: UnsignedInteger {
    public static var isSigned: Bool {
        return false
    }
    
    /// Returns `-1` if this value is negative and `1` if it’s positive; otherwise, `0`.
    ///
    /// - Returns: The sign of this number, expressed as an integer of the same type.
    public func signum() -> BigUInt {
        return isZero ? 0 : 1
    }
    
    /// The number of words used for the current binary representation of this value.
    public var countRepresentedWords: Int {
        return count
    }
    
    public func _word(at n: Int) -> UInt {
        // FIXME: This should not need to be overridden. See https://bugs.swift.org/browse/SR-5275
        return self[n]
    }
    
    public init?<T: BinaryInteger>(exactly source: T) {
        guard source >= 0 else { return nil }
        self.words = source.words
        shrink()
    }
    
    public init<T: BinaryInteger>(_ source: T) {
        self.init(exactly: source)!
    }
    
    public init<T: BinaryInteger>(extendingOrTruncating source: T) {
        self.words = source.words
        shrink()
    }
    
    public init<T: BinaryInteger>(clamping source: T) {
        if source < 0 {
            self.words = []
        }
        else {
            self.words = source.words
            shrink()
        }
    }
    
    public init?<T: FloatingPoint>(exactly source: T) {
        guard T.radix == 2 else {
            // FIXME
            fatalError("Conversions from non-base-2 floating point numbers aren't supported yet")
        }
        guard source.isFinite else { return nil }
        self.words = []
        var source = source.rounded(.towardZero)
        guard source.isZero || source.sign == .plus else { return nil }
        let unit = T(sign: .plus, exponent: numericCast(Word.bitWidth), significand: 1)
        while !source.isZero {
            let word = source.truncatingRemainder(dividingBy: unit)
            self.words.append(Word(word))
            source /= unit
        }
        shrink()
    }
    
    public init<T: FloatingPoint>(_ source: T) {
        self.init(exactly: source)!
    }
}

extension BigUInt {
    //MARK: Shrink
    
    /// Gets rid of leading zero digits in the digit array.
    internal mutating func shrink() {
        while words.last == 0 {
            words.removeLast()
        }
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
    public typealias Iterator = IndexingIterator<BigUInt>
    /// Big integers can be contiguous digit subranges of another big integer.
    public typealias SubSequence = BigUInt // FIXME this is wrong

    public var indices: Indices { return words.indices }

    /// The index of the first digit, starting from the least significant. (This is always zero.)
    public var startIndex: Int { return words.startIndex }
    /// The index of the digit after the most significant digit in this integer.
    public var endIndex: Int { return words.endIndex }
    /// The number of digits in this integer, excluding leading zero digits.
    public var count: Int { return words.count }

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
    public subscript(index: Int) -> Word {
        get {
            precondition(index >= 0)
            return (index < endIndex ? words[index] : 0)
        }
        set(word) {
            precondition(index >= 0)
            if index < endIndex {
                words[index] = word
                if word == 0 && index == endIndex - 1 {
                    shrink()
                }
            }
            else {
                guard word != 0 else { return }
                while index > endIndex { words.append(0) }
                words.append(word)
            }
        }
    }

    /// Returns an integer built from the digits of this integer in the given range.
    public subscript(bounds: Range<Int>) -> BigUInt {
        get {
            if bounds.lowerBound >= endIndex {
                return BigUInt()
            }
            return BigUInt(words: words[bounds.lowerBound ..< Swift.min(bounds.upperBound, endIndex)])
        }
    }
}

#if false // FIXME Reenable once BigInt works.
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
#endif

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
        return (self[mid ..< endIndex], self[startIndex ..< mid])
    }

    /// Index of the digit at the middle of this integer.
    ///
    /// - Returns: The index of the digit that is least significant in `self.high`.
    internal var middleIndex: Int {
        return startIndex + (count + 1) / 2
    }

    /// The low-order half of this BigUInt.
    ///
    /// - Returns: `self[0 ..< middleIndex]`
    /// - Requires: count > 1
    internal var low: BigUInt {
        return self[startIndex ..< middleIndex]
    }

    /// The high-order half of this BigUInt.
    ///
    /// - Returns: `self[middleIndex ..< count]`
    /// - Requires: count > 1
    internal var high: BigUInt {
        return self[middleIndex ..< endIndex]
    }
}

