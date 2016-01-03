//
//  BigUInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

public struct BigUInt {
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

    public init() {
        self.init([])
    }

    public init(_ digits: [Digit]) {
        self.init(digits: digits, start: 0, end: digits.count)
    }

    public init<I: UnsignedIntegerType>(_ integer: I) {
        self.init(Digit.digitsFromUIntMax(integer.toUIntMax()))
    }

    public init<I: SignedIntegerType>(_ integer: I) {
        precondition(integer >= 0)
        self.init(UIntMax(integer.toIntMax()))
    }
}

//MARK: Literals

extension BigUInt: IntegerLiteralConvertible {
    public init(integerLiteral value: UInt64) {
        self.init(value.toUIntMax())
    }
}

extension BigUInt: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = BigUInt(String(value), radix: 10)!
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = BigUInt(value, radix: 10)!
    }

    public init(stringLiteral value: StringLiteralType) {
        self = BigUInt(value, radix: 10)!
    }
}

//MARK: CollectionType

extension BigUInt: CollectionType {
    public var count: Int { return _end - _start }
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return count }

    public func generate() -> DigitGenerator<Digit> {
        return DigitGenerator(digits: _digits, end: _end, index: _start)
    }

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

    public subscript(range: Range<Int>) -> BigUInt {
        get {
            return BigUInt(digits: _digits, start: _start + range.startIndex, end: _start + range.endIndex)
        }
    }
}

public struct DigitGenerator<Digit>: GeneratorType {
    internal let digits: [Digit]
    internal let end: Int
    internal var index: Int

    public mutating func next() -> Digit? {
        guard index < end else { return nil }
        let v = digits[index]
        index += 1
        return v
    }
}


//MARK: Lift and shrink

extension BigUInt {
    internal var isTop: Bool { return _start == 0 && _end == _digits.count }
    internal mutating func lift() {
        guard !isTop else { return }
        _digits = Array(self)
        _start = 0
        _end = _digits.count
    }

    internal mutating func shrink() {
        assert(isTop)
        while _digits.last == 0 {
            _digits.removeLast()
        }
        _end = _digits.count
    }
}

//MARK: Conversion to and from String

extension BigUInt: CustomStringConvertible {

    private static func charsPerDigitForRadix(radix: Int) -> (chars: Int, power: Digit) {
        var power: Digit = 1
        var overflow = false
        var count = 0
        while !overflow {
            let (p, o) = Digit.multiplyWithOverflow(power, Digit(radix))
            overflow = o
            if !o || p == 0 {
                count += 1
                power = p
            }
        }
        return (count, power)
    }

    public init?(_ text: String, radix: Int = 10) {
        precondition(radix > 1)
        let (charsPerDigit, power) = BigUInt.charsPerDigitForRadix(radix)

        var digits: [Digit] = []
        var piece: String = ""
        var count = 0
        for c in text.characters.reverse() {
            piece.insert(c, atIndex: piece.startIndex)
            count += 1
            if count == charsPerDigit {
                guard let d = Digit(piece, radix: radix) else { return nil }
                digits.append(d)
                piece = ""
                count = 0
            }
        }
        if !piece.isEmpty {
            guard let d = Digit(piece, radix: radix) else { return nil }
            digits.append(d)
        }

        if power == 0 {
            self.init(digits)
        }
        else {
            self.init()
            for d in digits.reverse() {
                self.multiplyInPlaceByDigit(power)
                self.addDigitInPlace(d)
            }
        }
    }

    public var description: String {
        return String(self, radix: 10)
    }
}

extension String {
    public init(_ v: BigUInt) { self.init(v, radix: 10, uppercase: false) }
    
    public init(_ v: BigUInt, radix: Int, uppercase: Bool = false) {
        precondition(radix > 1)
        let (charsPerDigit, power) = BigUInt.charsPerDigitForRadix(radix)

        guard !v.isEmpty else { self = "0"; return }

        var parts: [String]
        if power == 0 {
            parts = v.map { String($0, radix: radix, uppercase: uppercase) }
        }
        else {
            parts = []
            var rest = v
            while !rest.isZero {
                let mod = rest.divideInPlaceByDigit(power)
                parts.append(String(mod, radix: radix, uppercase: uppercase))
            }
        }
        assert(!parts.isEmpty)

        self = ""
        var first = true
        for part in parts.reverse() {
            let zeroes = charsPerDigit - part.characters.count
            assert(zeroes >= 0)
            if !first && zeroes > 0 {
                // Insert leading zeroes for mid-digits
                self += String(count: zeroes, repeatedValue: "0" as Character)
            }
            first = false
            self += part
        }
    }
}

//MARK: Low and High

extension BigUInt {
    internal var split: (high: BigUInt, low: BigUInt) {
        precondition(count > 1)
        let mid = _start + (count + 1) / 2
        return (
            BigUInt(digits: _digits, start: mid, end: _end),
            BigUInt(digits: _digits, start: _start, end: mid)
        )
    }

    /// Returns the low-order half of this BigUInt.
    internal var low: BigUInt {
        return split.low
    }

    /// Returns the high-order half of this BigUInt.
    internal var high: BigUInt {
        return split.high
    }
}

//MARK: Comparable

extension BigUInt: Comparable {
    @warn_unused_result
    public static func compare(a: BigUInt, _ b: BigUInt) -> NSComparisonResult {
        if a.count != b.count { return a.count > b.count ? .OrderedDescending : .OrderedAscending }
        for i in (0..<a.count).reverse() {
            let ad = a[i]
            let bd = b[i]
            if ad != bd { return ad > bd ? .OrderedDescending : .OrderedAscending }
        }
        return .OrderedSame
    }
}

@warn_unused_result
public func ==(a: BigUInt, b: BigUInt) -> Bool {
    return BigUInt.compare(a, b) == .OrderedSame
}
@warn_unused_result
public func <(a: BigUInt, b: BigUInt) -> Bool {
    return BigUInt.compare(a, b) == .OrderedAscending
}

extension BigUInt {
    var isZero: Bool {
        return count == 0
    }
}

//MARK: Hashable

extension BigUInt: Hashable {
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

//MARK: Bitwise operations

extension BigUInt {
    /// The minimum number of bits required to represent this integer in binary.
    /// - Returns: floor(log2(2 * self + 1))
    public var width: Int {
        guard count > 0 else { return 0 }
        return count * Digit.width - self[count - 1].leadingZeroes
    }

    /// The number of leading zero bits in the binary representation of this integer in base `2^Digit.width`.
    /// This is useful when you need to normalize a `BigUInt` such that the top bit of its most significant digit is 1.
    /// - Note: 0 is considered to have zero leading zero bits.
    /// - Returns: A value in `0...(Digit.width - 1)`.
    /// - SeeAlso: width
    public var leadingZeroes: Int {
        guard count > 0 else { return 0 }
        return self[count - 1].leadingZeroes
    }

    /// The number of trailing zero bits in the binary representation of this integer. 
    /// - Note: 0 is considered to have zero trailing zero bits.
    /// - Returns: A value in `0...width`.
    public var trailingZeroes: Int {
        guard count > 0 else { return 0 }
        let i = self.indexOf { $0 != 0 }!
        return i * Digit.width + self[i].trailingZeroes
    }
}

@warn_unused_result
public prefix func ~(a: BigUInt) -> BigUInt {
    return BigUInt(a.map { ~$0 })
}

@warn_unused_result
public func | (a: BigUInt, b: BigUInt) -> BigUInt {
    var result = BigUInt()
    for i in (0 ..< max(a.count, b.count)).reverse() {
        result[i] = a[i] | b[i]
    }
    return result
}

@warn_unused_result
public func & (a: BigUInt, b: BigUInt) -> BigUInt {
    var result = BigUInt()
    for i in (0 ..< max(a.count, b.count)).reverse() {
        result[i] = a[i] & b[i]
    }
    return result
}

@warn_unused_result
public func ^ (a: BigUInt, b: BigUInt) -> BigUInt {
    var result = BigUInt()
    for i in (0 ..< max(a.count, b.count)).reverse() {
        result[i] = a[i] ^ b[i]
    }
    return result
}

public func |= (inout a: BigUInt, b: BigUInt) {
    a = a | b
}
public func &= (inout a: BigUInt, b: BigUInt) {
    a = a & b
}
public func ^= (inout a: BigUInt, b: BigUInt) {
    a = a ^ b
}


//MARK: Addition

extension BigUInt {
    public mutating func addDigitInPlace(d: Digit, shift: Int = 0) {
        precondition(shift >= 0)
        lift()
        var carry: Digit = d
        var i = shift
        while carry > 0 {
            let (d, c) = Digit.addWithOverflow(self[i], carry)
            self[i] = d
            carry = (c ? 1 : 0)
            i += 1
        }
    }

    public mutating func addInPlace(b: BigUInt, shift: Int = 0) {
        precondition(shift >= 0)
        lift()
        var carry = false
        var bi = 0
        while bi < b.count || carry {
            let ai = shift + bi
            let (d, c) = Digit.addWithOverflow(self[ai], b[bi])
            if carry {
                let (d2, c2) = Digit.addWithOverflow(d, 1)
                self[ai] = d2
                carry = c || c2
            }
            else {
                self[ai] = d
                carry = c
            }
            bi += 1
        }
    }

    @warn_unused_result
    public func add(b: BigUInt, shift: Int = 0) -> BigUInt {
        var r = self
        r.addInPlace(b, shift: shift)
        return r
    }

    @warn_unused_result
    public func addDigit(d: Digit, shift: Int = 0) -> BigUInt {
        var r = self
        r.addDigitInPlace(d, shift: shift)
        return r
    }

    public mutating func increment(shift shift: Int = 0) {
        self.addDigitInPlace(1, shift: shift)
    }
}

@warn_unused_result
public func +(a: BigUInt, b: BigUInt) -> BigUInt {
    return a.add(b)
}

public func +=(inout a: BigUInt, b: BigUInt) {
    a.addInPlace(b, shift: 0)
}

//MARK: Subtraction

extension BigUInt {
    @warn_unused_result
    public mutating func subtractDigitInPlaceWithOverflow(d: Digit, shift: Int = 0) -> Bool {
        precondition(shift >= 0)
        lift()
        var carry: Digit = d
        var i = shift
        while carry > 0 && i < count {
            let (d, c) = Digit.subtractWithOverflow(self[i], carry)
            self[i] = d
            carry = (c ? 1 : 0)
            i += 1
        }
        return carry > 0
    }

    @warn_unused_result
    public func subtractDigitWithOverflow(d: Digit, shift: Int = 0) -> (BigUInt, overflow: Bool) {
        var result = self
        let overflow = result.subtractDigitInPlaceWithOverflow(d, shift: shift)
        return (result, overflow)
    }

    public mutating func subtractDigitInPlace(d: Digit, shift: Int = 0) {
        let overflow = subtractDigitInPlaceWithOverflow(d, shift: shift)
        precondition(!overflow)
    }

    @warn_unused_result
    public func subtractDigit(d: Digit, shift: Int = 0) -> BigUInt {
        var result = self
        result.subtractDigitInPlace(d, shift: shift)
        return result
    }

    @warn_unused_result
    public mutating func subtractInPlaceWithOverflow(b: BigUInt, shift: Int = 0) -> Bool {
        precondition(shift >= 0)
        lift()
        var carry = false
        var bi = 0
        while bi < b.count || (shift + bi < count && carry) {
            let ai = shift + bi
            let (d, c) = Digit.subtractWithOverflow(self[ai], b[bi])
            if carry {
                let (d2, c2) = Digit.subtractWithOverflow(d, 1)
                self[ai] = d2
                carry = c || c2
            }
            else {
                self[ai] = d
                carry = c
            }
            bi += 1
        }
        return carry
    }

    @warn_unused_result
    public func subtractWithOverflow(b: BigUInt, shift: Int = 0) -> (BigUInt, Bool) {
        var result = self
        let overflow = result.subtractInPlaceWithOverflow(b, shift: shift)
        return (result, overflow)
    }

    public mutating func subtractInPlace(b: BigUInt, shift: Int = 0) {
        let overflow = subtractInPlaceWithOverflow(b, shift: shift)
        precondition(!overflow)
    }

    @warn_unused_result
    public func subtract(b: BigUInt, shift: Int = 0) -> BigUInt {
        var result = self
        result.subtractInPlace(b, shift: shift)
        return result
    }

    public mutating func decrement(shift shift: Int = 0) {
        self.subtractDigitInPlace(1, shift: shift)
    }
}

@warn_unused_result
public func -(a: BigUInt, b: BigUInt) -> BigUInt {
    return a.subtract(b)
}

public func -=(inout a: BigUInt, b: BigUInt) {
    a.subtractInPlace(b, shift: 0)
}

//MARK: Multiplication

extension BigUInt {
    public mutating func multiplyInPlaceByDigit(y: Digit) {
        guard y != 0 else { self = 0; return }
        guard y != 1 else { return }
        lift()
        var carry: Digit = 0
        let c = self.count
        for i in 0..<c {
            let (h, l) = Digit.fullMultiply(self[i], y)
            let (low, o) = Digit.addWithOverflow(l, carry)
            self[i] = low
            carry = (o ? h + 1 : h)
        }
        self[c] = carry
    }

    @warn_unused_result
    public func multiplyByDigit(y: Digit) -> BigUInt {
        var r = self
        r.multiplyInPlaceByDigit(y)
        return r
    }

    /// Add `x * y` to this integer, optionally shifted by `shift` digits to the right.
    public mutating func multiplyAndAddInPlace(x: BigUInt, _ y: Digit, shift: Int = 0) {
        precondition(shift >= 0)
        guard y != 0 && x.count > 0 else { return }
        guard y != 1 else { self.addInPlace(x, shift: shift); return }
        lift()
        var mulCarry: Digit = 0
        var addCarry = false
        let xc = x.count
        var xi = 0
        while xi < xc || addCarry || mulCarry > 0 {
            let (h, l) = Digit.fullMultiply(x[xi], y)
            let (low, o) = Digit.addWithOverflow(l, mulCarry)
            mulCarry = (o ? h + 1 : h)

            let ai = shift + xi
            let (sum1, so1) = Digit.addWithOverflow(self[ai], low)
            if addCarry {
                let (sum2, so2) = Digit.addWithOverflow(sum1, 1)
                self[ai] = sum2
                addCarry = so1 || so2
            }
            else {
                self[ai] = sum1
                addCarry = so1
            }
            xi += 1
        }
    }
}

extension BigUInt {
    static var directMultiplicationLimit: Int = 1024
}

@warn_unused_result
public func *(x: BigUInt, y: BigUInt) -> BigUInt {
    let xc = x.count
    let yc = y.count
    if xc == 0 { return BigUInt() }
    if yc == 0 { return BigUInt() }
    if yc == 1 { return x.multiplyByDigit(y[0]) }
    if xc == 1 { return y.multiplyByDigit(x[0]) }

    if min(xc, yc) <= BigUInt.directMultiplicationLimit {
        // Long multiplication.
        let left = (xc < yc ? y : x)
        let right = (xc < yc ? x : y)
        var result = BigUInt()
        for i in (0 ..< right.count).reverse() {
            result.multiplyAndAddInPlace(left, right[i], shift: i)
        }
        return result
    }

    if yc < xc {
        let (xh, xl) = x.split
        var r = xl * y
        r.addInPlace(xh * y, shift: (xc + 1) / 2)
        return r
    }
    else if xc < yc {
        let (yh, yl) = y.split
        var r = yl * x
        r.addInPlace(yh * x, shift: (yc + 1) / 2)
        return r
    }

    let shift = (xc + 1) / 2

    // Karatsuba multiplication:
    // x * y = <a,b> * <c,d> = <ac, ac + bd - (a-b)(c-d), bd> (ignoring carry)
    let (a, b) = x.split
    let (c, d) = y.split

    let high = a * c
    let low = b * d
    let xp = a >= b
    let yp = c >= d
    let xm = (xp ? a - b : b - a)
    let ym = (yp ? c - d : d - c)
    let m = xm * ym

    var r = low
    r.addInPlace(high, shift: 2 * shift)
    r.addInPlace(low, shift: shift)
    r.addInPlace(high, shift: shift)
    if xp == yp {
        r.subtractInPlace(m, shift: shift)
    }
    else {
        r.addInPlace(m, shift: shift)
    }
    return r
}

public func *=(inout a: BigUInt, b: BigUInt) {
    a = a * b
}

//MARK: Bitwise Shifts

public func <<= (inout b: BigUInt, amount: Int) {
    typealias Digit = BigUInt.Digit

    precondition(amount >= 0)
    guard amount > 0 else { return }

    let ext = amount / Digit.width // External shift amount (new digits)
    let up = Digit(amount % Digit.width) // Internal shift amount (subdigit shift)
    let down = Digit(Digit.width) - up

    b.lift()
    if up > 0 {
        var i = 0
        var lowbits: Digit = 0
        while i < b.count || lowbits > 0 {
            let digit = b[i]
            b[i] = digit << up | lowbits
            lowbits = digit >> down
            i += 1
        }
    }
    if ext > 0 && b.count > 0 {
        b._digits.insertContentsOf(Array<Digit>(count: ext, repeatedValue: 0), at: 0)
        b._end = b._digits.count
    }
}

@warn_unused_result
public func << (b: BigUInt, amount: Int) -> BigUInt {
    typealias Digit = BigUInt.Digit

    precondition(amount >= 0)
    guard amount > 0 else { return b }

    let ext = amount / Digit.width // External shift amount (new digits)
    let up = Digit(amount % Digit.width) // Internal shift amount (subdigit shift)
    let down = Digit(Digit.width) - up

    var result = BigUInt()
    if up > 0 {
        var i = 0
        var lowbits: Digit = 0
        while i < b.count || lowbits > 0 {
            let digit = b[i]
            result[i + ext] = digit << up | lowbits
            lowbits = digit >> down
            i += 1
        }
    }
    else {
        for i in 0..<b.count {
            result[i + ext] = b[i]
        }
    }
    return result
}

public func >>= (inout b: BigUInt, amount: Int) {
    typealias Digit = BigUInt.Digit

    precondition(amount >= 0)
    guard amount > 0 else { return }

    let ext = amount / Digit.width // External shift amount (new digits)
    let down = Digit(amount % Digit.width) // Internal shift amount (subdigit shift)
    let up = Digit(Digit.width) - down

    if ext >= b.count {
        b = BigUInt()
        return
    }

    b.lift()

    if ext > 0 {
        b._digits.removeRange(Range(start: 0, end: ext))
        b._end = b._digits.count
    }
    if down > 0 {
        var i = b.count - 1
        var highbits: Digit = 0
        while i >= 0 {
            let digit = b[i]
            b[i] = highbits | digit >> down
            highbits = digit << up
            i -= 1
        }
        b.shrink()
    }
}

@warn_unused_result
public func >> (b: BigUInt, amount: Int) -> BigUInt {
    typealias Digit = BigUInt.Digit

    precondition(amount >= 0)
    guard amount > 0 else { return b }

    let ext = amount / Digit.width // External shift amount (new digits)
    let down = Digit(amount % Digit.width) // Internal shift amount (subdigit shift)
    let up = Digit(Digit.width) - down

    if ext >= b.count { return BigUInt() }

    var result = BigUInt()
    if down > 0 {
        var highbits: Digit = 0
        for i in (ext..<b.count).reverse() {
            let digit = b[i]
            result[i - ext] = highbits | digit >> down
            highbits = digit << up
        }
    }
    else {
        for i in (ext..<b.count).reverse() {
            result[i - ext] = b[i]
        }
    }
    return result
}


//MARK: Quotient and Remainder

extension BigUInt {
    /// Divide this integer by the digit `y`, leaving the quotient in its place and returning the remainder.
    /// - Requires: y > 0
    /// - Complexity: O(count)
    @warn_unused_result
    public mutating func divideInPlaceByDigit(y: Digit) -> Digit {
        precondition(y > 0)
        if y == 1 { return 0 }
        lift()

        var remainder: Digit = 0
        for i in (0..<count).reverse() {
            let u = self[i]
            let q = Digit.fullDivide(remainder, u, y)
            self[i] = q.div
            remainder = q.mod
        }
        return remainder
    }

    /// Divide this integer by the digit `y` and return the resulting quotient and remainder.
    @warn_unused_result
    /// - Requires: y > 0
    /// - Returns: (div, mod) where div = floor(x/y), mod = x - div * y
    /// - Complexity: O(x.count)
    public func divideByDigit(y: Digit) -> (div: BigUInt, mod: Digit) {
        var div = self
        let mod = div.divideInPlaceByDigit(y)
        return (div, mod)
    }

    /// Divide this integer by `y` and return the resulting quotient and remainder.
    /// - Requires: y > 0
    /// - Returns: (div, mod) where div = floor(x/y), mod = x - div * y
    /// - Complexity: O(x.count * y.count)
    @warn_unused_result
    public func divide(y: BigUInt) -> (div: BigUInt, mod: BigUInt) {
        // This is a Swift adaptation of "divmnu" from Hacker's Delight, which is in
        // turn a C adaptation of Knuth's Algorithm D (TAOCP vol 2, 4.3.1).

        precondition(y.count > 0)

        // First, let's take care of the easy cases.

        if self.count < y.count {
            return (0, self)
        }
        if y.count == 1 {
            // The single-digit case reduces to a simpler loop.
            let (div, mod) = divideByDigit(y[0])
            return (div, BigUInt(mod))
        }
        
        // This function simply performs the long division algorithm we learned in school.
        // It works by successively calculating the remainder of the top y.count digits of x
        // under y, and subtracting it from the top of x while remembering the quotient.
        //
        // The tricky part is that the algorithm needs to be able to divide two equal-sized
        // big integers, but we only have a primitive for dividing two digits by a single
        // digit. (Remember that this step is also tricky when we do it on paper!)
        //
        // The solution is that the long division can be approximated by a single fullDivide
        // using just the most significant digits. We can then use multiplications and 
        // subtractions to refine the approximation until we get the correct quotient digit.

        // We could do this by doing a simple 2/1 fullDivide, but Knuth goes one step further,
        // and implements a 3/2 division. This results in an exact approximation in the 
        // vast majority of cases, eliminating the need for some long subtractions.
        // Here is the code for the 3/2 division:

        /// Return the 3/2-sized quotient `x/y` as a single Digit.
        /// - Requires: (x.0, x.1) <= y && y.0.high != 0
        /// - Returns: Digit.max when the quotient doesn't fit in a single digit, or an exact value.
        func approximateQuotient(x x: (Digit, Digit, Digit), y: (Digit, Digit)) -> Digit {
            // Start with q = (x.0, x.1) / y.0, (or Digit.max on overflow)
            var q: Digit
            var r: Digit
            if x.0 == y.0 {
                q = Digit.max
                let (s, o) = Digit.addWithOverflow(x.0, x.1)
                if o { return q }
                r = s
            }
            else {
                let (d, m) = Digit.fullDivide(x.0, x.1, y.0)
                q = d
                r = m
            }
            // Now refine q by considering x.2 and y.1. 
            // Note that since y is normalized, q - x/y is between 0 and 2.
            var p = Digit.fullMultiply(q, y.1)
            while p.0 > r || (p.0 == r && p.1 > x.2) {
                q -= 1
                let (a, ao) = Digit.addWithOverflow(r, y.0)
                if ao {
                    return q
                }
                r = a
                let (s, so) = Digit.subtractWithOverflow(p.1, y.1)
                if so { p.0 -= 1 }
                p.1 = s
            }
            return q
        }

        // The function above requires that the divisor's most significant digit is larger than
        // Digit.max / 2. This ensures that the approximation has tiny error bounds,
        // which is what makes this entire approach viable.
        // To satisfy this requirement, we can simply normalize the division by multiplying
        // both the divisor and the dividend by the same (small) factor.
        let z = y.leadingZeroes
        let divisor = y << z
        var remainder = self << z // We'll calculate the remainder in the normalized dividend.
        var quotient = BigUInt()
        assert(divisor.count == y.count && divisor.last!.high > 0)

        // We're ready to start the long division!
        let dc = divisor.count
        let d1 = divisor[dc - 1]
        let d0 = divisor[dc - 2]
        for j in (dc ... remainder.count).reverse() {
            // Approximate dividing the top dc digits of remainder using the topmost 3/2 digits.
            let r2 = remainder[j]
            let r1 = remainder[j - 1]
            let r0 = remainder[j - 2]
            let q = approximateQuotient(x: (r2, r1, r0), y: (d1, d0))

            // Multiply q with the whole divisor and subtract the result from remainder.
            // Normalization ensures the 3/2 quotient will either be exact for the full division, or
            // it may overshoot by at most 1, in which case the product will be greater
            // than remainder.
            let product = divisor.multiplyByDigit(q)
            assert(remainder.isTop) // Or all the copying will lead to a 850% slowdown.
            if product <= remainder[j - dc ... j] {
                remainder.subtractInPlace(product, shift: j - dc)
                quotient[j - dc] = q
            }
            else {
                // This case is extremely rare -- it has a probability of 1/2^(Digit.width - 1).
                remainder.subtractInPlace(product - divisor, shift: j - dc)
                quotient[j - dc] = q - 1
            }
        }
        // The remainder's normalization needs to be undone, but otherwise we're done.
        return (quotient, remainder >> z)
    }
}

/// Divide `x` by `y` and return the quotient.
/// - Note: Use `x.divide(y)` if you also need the remainder.
@warn_unused_result
public func /(x: BigUInt, y: BigUInt) -> BigUInt {
    return x.divide(y).div
}

/// Divide `x` by `y` and return the remainder.
/// - Note: Use `x.divide(y)` if you also need the remainder.
@warn_unused_result
public func %(x: BigUInt, y: BigUInt) -> BigUInt {
    return x.divide(y).mod
}

/// Divide `x` by `y` and store the quotient of the result in `x`.
/// - Note: Use `x.divide(y)` if you also need the remainder.
public func /=(inout x: BigUInt, y: BigUInt) {
    x = x.divide(y).div
}

/// Divide `x` by `y` and store the remainder of the result in `x`.
/// - Note: Use `x.divide(y)` if you also need the remainder.
public func %=(inout x: BigUInt, y: BigUInt) {
    x = x.divide(y).mod
}

/// Returns the integer square root of a big integer; i.e., the largest integer whose square isn't greater than `value`.
/// - Returns: floor(sqrt(value))
@warn_unused_result
public func sqrt(value: BigUInt) -> BigUInt {
    // This implementation uses Newton's method.
    guard !value.isZero else { return BigUInt() }
    var x = BigUInt(1) << ((value.width + 1) / 2)
    while true {
        let y = (x + value / x) >> 1
        if x == y || x == y - 1 { break }
        x = y
    }
    return x
}

extension BigUInt {

    /// Returns the greatest common divisor of `a` and `b`.
    /// - Complexity: O(count^2) where count = max(a.count, b.count)
    @warn_unused_result
    public static func gcd(a: BigUInt, _ b: BigUInt) -> BigUInt {
        // This is Stein's algorithm: https://en.wikipedia.org/wiki/Binary_GCD_algorithm
        if a.isZero || b.isZero { return BigUInt() }

        let az = a.trailingZeroes
        let bz = b.trailingZeroes
        let twos = min(az, bz)

        var (x, y) = (a >> az, b >> bz)
        if x < y { swap(&x, &y) }

        while !x.isZero {
            x >>= x.trailingZeroes
            if x < y { swap(&x, &y) }
            x -= y
        }
        return y << twos
    }

    /// Returns the remainder of `base` raised to the power `exponent` under `modulus`.
    /// - Complexity: O(exponent.count * modulus.count^2)
    @warn_unused_result
    public static func powmod(base: BigUInt, _ exponent: BigUInt, modulus: BigUInt) -> BigUInt {
        // https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
        if modulus == 1 { return 0 }
        var result = BigUInt(1)
        var b = base % modulus
        var e = exponent
        while e > 0 {
            if e[0] & 1 == 1 {
                result = (result * b) % modulus
            }
            e >>= 1
            b = (b * b) % modulus
        }
        return result
    }
}
