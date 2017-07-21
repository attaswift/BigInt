//
//  BigInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import SipHash

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
    public enum Sign {
        case plus
        case minus
    }

    public typealias Magnitude = BigUInt

    /// The type representing a digit in `BigInt`'s underlying number system.
    public typealias Word = BigUInt.Word
    
    /// The absolute value of this integer.
    public var magnitude: BigUInt

    /// True iff the value of this integer is negative.
    public var sign: Sign

    @available(*, unavailable, renamed: "magnitude")
    public var abs: BigUInt { return magnitude }

    @available(*, unavailable, renamed: "sign")
    public var negative: Bool { return sign == .minus }

    /// Initializes a new big integer with the provided absolute number and sign flag.
    public init(sign: Sign, magnitude: BigUInt) {
        self.sign = (magnitude.isZero ? .plus : sign)
        self.magnitude = magnitude
    }
}

extension Array where Element == UInt {
    mutating func twosComplement() {
        var increment = true
        for i in 0 ..< self.count {
            if increment {
                let r = (~self[i]).addingReportingOverflow(1)
                self[i] = r.partialValue
                increment = r.overflow == .overflow
            }
            else {
                self[i] = ~self[i]
            }
        }
    }
}

extension BigInt: BinaryInteger {
    public init() {
        self.init(sign: .plus, magnitude: 0)
    }

    /// Initializes a new signed big integer with the same value as the specified unsigned big integer.
    public init(_ integer: BigUInt) {
        self.magnitude = integer
        self.sign = .plus
    }

    public init<T>(_ source: T) where T : BinaryInteger {
        if source >= (0 as T) {
            self.init(sign: .plus, magnitude: BigUInt(source))
        }
        else {
            var words = Array(source.words)
            words.twosComplement()
            self.init(sign: .minus, magnitude: BigUInt(words: words))
        }
    }

    public init<T>(_ source: T) where T : FloatingPoint {
        if source.sign == .plus {
            self.init(sign: .plus, magnitude: BigUInt(source))
        }
        else {
            self.init(sign: .minus, magnitude: BigUInt(-source))
        }
    }

    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(source)
    }

    public init?<T>(exactly source: T) where T : FloatingPoint {
        guard source.floatingPointClass == .positiveNormal || source.floatingPointClass == .negativeNormal else { return nil }
        guard source.rounded(.towardZero) == source else { return nil }
        self.init(source)
    }

    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(source)
    }

    public init<T>(extendingOrTruncating source: T) where T : BinaryInteger {
        self.init(source)
    }
}

extension BigInt {
    public static var isSigned: Bool {
        return true
    }

    public var bitWidth: Int {
        return magnitude.bitWidth + 1
    }

    public var trailingZeroBitCount: Int {
        // FIXME negative values?
        return magnitude.trailingZeroBitCount
    }

    public struct Words: RandomAccessCollection {
        public typealias Indices = CountableRange<Int>

        private let value: BigInt
        private let decrementLimit: Int

        fileprivate init(_ value: BigInt) {
            self.value = value
            switch value.sign {
            case .plus:
                self.decrementLimit = 0
            case .minus:
                assert(!value.magnitude.isZero)
                self.decrementLimit = value.magnitude.words.index(where: { $0 != 0 })!
            }
        }

        public var count: Int {
            switch value.sign {
            case .plus:
                if let high = value.magnitude.words.last, high >> (Word.bitWidth - 1) != 0 {
                    return value.magnitude.count + 1
                }
                return value.magnitude.count
            case .minus:
                let high = value.magnitude.words.last!
                if high >> (Word.bitWidth - 1) != 0 {
                    return value.magnitude.count + 1
                }
                return value.magnitude.count
            }
        }

        public var indices: Indices { return 0 ..< count }
        public var startIndex: Int { return 0 }
        public var endIndex: Int { return count }

        public subscript(_ index: Int) -> UInt {
            // Note that indices above `endIndex` are accepted.
            if value.sign == .plus {
                return value.magnitude[index]
            }
            else if index <= decrementLimit {
                return ~(value.magnitude[index] &- 1)
            }
            else {
                return ~value.magnitude[index]
            }
        }
    }

    public var words: Words {
        return Words(self)
    }

    // FIXME: Remove this
    public func _word(at n: Int) -> UInt {
        return words[n]
    }
}

extension BigInt {
    public static prefix func ~(x: BigInt) -> BigInt {
        switch x.sign {
        case .plus:
            return BigInt(sign: .minus, magnitude: x.magnitude + 1)
        case .minus:
            return BigInt(sign: .plus, magnitude: x.magnitude - 1)
        }
    }

    public static func &(lhs: inout BigInt, rhs: BigInt) -> BigInt {
        let left = lhs.words
        let right = rhs.words
        // Note we aren't using left.count/right.count here; we account for the sign bit separately later.
        let count = Swift.max(lhs.magnitude.count, rhs.magnitude.count)
        var words: [UInt] = []
        words.reserveCapacity(count)
        for i in 0 ..< count {
            words.append(left[i] & right[i])
        }
        if lhs.sign == .minus && rhs.sign == .minus {
            words.twosComplement()
            return BigInt(sign: .minus, magnitude: BigUInt(words: words))
        }
        else {
            return BigInt(sign: .plus, magnitude: BigUInt(words: words))
        }
    }

    public static func |(lhs: inout BigInt, rhs: BigInt) -> BigInt {
        let left = lhs.words
        let right = rhs.words
        // Note we aren't using left.count/right.count here; we account for the sign bit separately later.
        let count = Swift.max(lhs.magnitude.count, rhs.magnitude.count)
        var words: [UInt] = []
        words.reserveCapacity(count)
        for i in 0 ..< count {
            words.append(left[i] | right[i])
        }
        if lhs.sign == .minus || rhs.sign == .minus {
            words.twosComplement()
            return BigInt(sign: .minus, magnitude: BigUInt(words: words))
        }
        else {
            return BigInt(sign: .plus, magnitude: BigUInt(words: words))
        }
    }

    public static func ^(lhs: inout BigInt, rhs: BigInt) -> BigInt {
        let left = lhs.words
        let right = rhs.words
        // Note we aren't using left.count/right.count here; we account for the sign bit separately later.
        let count = Swift.max(lhs.magnitude.count, rhs.magnitude.count)
        var words: [UInt] = []
        words.reserveCapacity(count)
        for i in 0 ..< count {
            words.append(left[i] ^ right[i])
        }
        if (lhs.sign == .minus) != (rhs.sign == .minus) {
            words.twosComplement()
            return BigInt(sign: .minus, magnitude: BigUInt(words: words))
        }
        else {
            return BigInt(sign: .plus, magnitude: BigUInt(words: words))
        }
    }

    public static func &=(lhs: inout BigInt, rhs: BigInt) {
        lhs = lhs & rhs
    }

    public static func |=(lhs: inout BigInt, rhs: BigInt) {
        lhs = lhs | rhs
    }

    public static func ^=(lhs: inout BigInt, rhs: BigInt) {
        lhs = lhs ^ rhs
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
        self.init(Substring(text), radix: radix)
    }

    public init?<S: StringProtocol>(_ text: S, radix: Int = 10) {
        self.init(Substring(text), radix: radix)
    }

    init?(_ text: Substring, radix: Int = 10) {
        var text = text
        var sign: Sign = .plus
        if text.characters.first == "-" {
            sign = .minus
            text = text[text.index(after: text.startIndex)...]
        }
        else if text.characters.first == "+" {
            text = text[text.index(after: text.startIndex)...]
        }
        guard let magnitude = BigUInt(text, radix: radix) else { return nil }
        self.magnitude = magnitude
        self.sign = sign
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
        self = String(value.magnitude, radix: radix, uppercase: uppercase)
        if value.sign == .minus {
            self = "-" + self
        }
    }
}

extension BigInt: CustomStringConvertible {
    /// Return the decimal representation of this integer.
    public var description: String { return String(self, radix: 10) }
}

extension BigInt: ExpressibleByIntegerLiteral {
    /// Initialize a new big integer from an integer literal.
    public init(integerLiteral value: Int64) {
        self.init(value)
    }
}

extension BigInt: ExpressibleByStringLiteral {
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
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let text = String(self)
        return PlaygroundQuickLook.text(text + " (\(self.magnitude.bitWidth) bits)")
    }
}

extension BigInt: Comparable {
    /// Return true iff `a` is equal to `b`.
    public static func ==(a: BigInt, b: BigInt) -> Bool {
        return a.sign == b.sign && a.magnitude == b.magnitude
    }

    /// Return true iff `a` is less than `b`.
    public static func <(a: BigInt, b: BigInt) -> Bool {
        switch (a.sign, b.sign) {
        case (.plus, .plus):
            return a.magnitude < b.magnitude
        case (.plus, .minus):
            return false
        case (.minus, .plus):
            return true
        case (.minus, .minus):
            return a.magnitude > b.magnitude
        }
    }
}

extension BigInt: SipHashable {
    /// Append this `BigInt` to the specified hasher.
    public func appendHashes(to hasher: inout SipHasher) {
        hasher.append(sign)
        hasher.append(magnitude)
    }
}

extension BigInt: Strideable {
    /// A type that can represent the distance between two values of `BigInt`.
    public typealias Stride = BigInt

    /// Returns `self + n`.
    public func advanced(by n: Stride) -> BigInt {
        return self + n
    }

    /// Returns `other - self`.
    public func distance(to other: BigInt) -> Stride {
        return other - self
    }
}

extension BigInt: SignedNumeric {
    public mutating func negate() {
        guard !magnitude.isZero else { return }
        self.sign = self.sign == .plus ? .minus : .plus
    }
}

extension BigInt {
    /// Add `a` to `b` and return the result.
    public static func +(a: BigInt, b: BigInt) -> BigInt {
        switch (a.sign, b.sign) {
        case (.plus, .plus):
            return BigInt(sign: .plus, magnitude: a.magnitude + b.magnitude)
        case (.minus, .minus):
            return BigInt(sign: .minus, magnitude: a.magnitude + b.magnitude)
        case (.plus, .minus):
            if a.magnitude >= b.magnitude {
                return BigInt(sign: .plus, magnitude: a.magnitude - b.magnitude)
            }
            else {
                return BigInt(sign: .minus, magnitude: b.magnitude - a.magnitude)
            }
        case (.minus, .plus):
            if b.magnitude >= a.magnitude {
                return BigInt(sign: .plus, magnitude: b.magnitude - a.magnitude)
            }
            else {
                return BigInt(sign: .minus, magnitude: a.magnitude - b.magnitude)
            }
        }
    }

    /// Subtract `b` from `a` and return the result.
    public static func -(a: BigInt, b: BigInt) -> BigInt {
        return a + -b
    }

    /// Multiply `a` with `b` and return the result.
    public static func *(a: BigInt, b: BigInt) -> BigInt {
        return BigInt(sign: a.sign == b.sign ? .plus : .minus, magnitude: a.magnitude * b.magnitude)
    }

    /// Divide `a` by `b` and return the quotient. Traps if `b` is zero.
    public static func /(a: BigInt, b: BigInt) -> BigInt {
        return BigInt(sign: a.sign == b.sign ? .plus : .minus, magnitude: a.magnitude / b.magnitude)
    }

    /// Divide `a` by `b` and return the remainder. The result has the same sign as `a`.
    public static func %(a: BigInt, b: BigInt) -> BigInt {
        return BigInt(sign: a.sign, magnitude: a.magnitude % b.magnitude)
    }
  
    /// Return the result of `a` mod `b`. The result is always a nonnegative integer that is less than the absolute value of `b`.
    public static func modulus(_ a: BigInt,_ b: BigInt) -> BigInt {
        let remainder = a.magnitude % b.magnitude
        return BigInt(sign: .plus,
                      magnitude: a.sign == .minus && !remainder.isZero ? b.magnitude - remainder : remainder)
    }
}

extension BigInt {
    /// Add `b` to `a` in place.
    public static func +=(a: inout BigInt, b: BigInt) { a = a + b }
    /// Subtract `b` from `a` in place.
    public static func -=(a: inout BigInt, b: BigInt) { a = a - b }
    /// Multiply `a` with `b` in place.
    public static func *=(a: inout BigInt, b: BigInt) { a = a * b }
    /// Divide `a` by `b` storing the quotient in `a`.
    public static func /=(a: inout BigInt, b: BigInt) { a = a / b }
    /// Divide `a` by `b` storing the remainder in `a`.
    public static func %=(a: inout BigInt, b: BigInt) { a = a % b }
}

extension BigInt {
    func shiftedLeft(by amount: Word) -> BigInt {
        return BigInt(sign: self.sign, magnitude: self.magnitude.shiftedLeft(by: amount))
    }

    mutating func shiftLeft(by amount: Word) {
        self.magnitude.shiftLeft(by: amount)
    }

    func shiftedRight(by amount: Word) -> BigInt {
        let m = self.magnitude.shiftedRight(by: amount)
        return BigInt(sign: self.sign, magnitude: self.sign == .minus && m.isZero ? 1 : m)
    }

    mutating func shiftRight(by amount: Word) {
        magnitude.shiftRight(by: amount)
        if sign == .minus, magnitude.isZero {
            magnitude = 1
        }
    }

    public static func &<<(left: BigInt, right: BigInt) -> BigInt {
        return left.shiftedLeft(by: right.words[0])
    }

    public static func &<<=(left: inout BigInt, right: BigInt) {
        left.shiftLeft(by: right.words[0])
    }

    public static func &>>(left: BigInt, right: BigInt) -> BigInt {
        return left.shiftedRight(by: right.words[0])
    }

    public static func &>>=(left: inout BigInt, right: BigInt) {
        left.shiftRight(by: right.words[0])
    }

    public static func <<<Other: BinaryInteger>(lhs: BigInt, rhs: Other) -> BigInt {
        if rhs < (0 as Other) {
            return lhs >> (0 - rhs)
        }
        return lhs.shiftedLeft(by: Word(rhs))
    }

    public static func <<=<Other: BinaryInteger>(lhs: inout BigInt, rhs: Other) {
        if rhs < (0 as Other) {
            lhs >>= (0 - rhs)
        }
        else {
            lhs.shiftLeft(by: Word(rhs))
        }
    }

    public static func >><Other: BinaryInteger>(lhs: BigInt, rhs: Other) -> BigInt {
        if rhs < (0 as Other) {
            return lhs << (0 - rhs)
        }
        else {
            return lhs.shiftedRight(by: Word(rhs))
        }
    }

    public static func >>=<Other: BinaryInteger>(lhs: inout BigInt, rhs: Other) {
        if rhs < (0 as Other) {
            lhs <<= (0 - rhs)
        }
        lhs.shiftRight(by: Word(rhs))
    }
}
