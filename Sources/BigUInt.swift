//
//  BigUInt.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

public struct BigUInt {
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
        var digits = Array<Digit>()
        var remaining = integer.toUIntMax()
        var rank = Int(remaining.rank)
        let chunk = 8 * sizeof(Digit)
        while rank >= chunk {
            digits.append(Digit(remaining & UIntMax(Digit.max)))
            remaining >>= UIntMax(chunk)
            rank -= chunk
        }
        digits.append(Digit(remaining))
        self.init(digits)
    }

    public init<I: SignedIntegerType>(_ integer: I) {
        precondition(integer >= 0)
        self.init(UIntMax(integer.toIntMax()))
    }
}

//MARK: Initializers

extension BigUInt: IntegerLiteralConvertible {
    public init(integerLiteral value: UInt64) {
        self.init(value.toUIntMax())
    }
}

//MARK: CollectionType

extension BigUInt: CollectionType {
    public var count: Int { return _end - _start }
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return count }

    public func generate() -> DigitsGenerator {
        return DigitsGenerator(digits: _digits, end: _end, index: _start)
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

public struct DigitsGenerator: GeneratorType {
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
        while _end > _start && _digits[_end - 1] == 0 {
            _end -= 1
        }
    }
}

//MARK: Conversion to and from String

extension BigUInt: CustomStringConvertible {

    public init?(_ text: String) {
        var digits: [Digit] = []

        let charsPerDigit = 2 * sizeof(Digit)

        var piece = ""
        for c in text.characters.reverse() {
            piece.insert(c, atIndex: piece.startIndex)
            if piece.characters.count == charsPerDigit {
                guard let d = Digit(piece, radix: 16) else { return nil }
                digits.append(d)
                piece = ""
            }
        }
        guard let d = Digit("0" + piece, radix: 16) else { return nil }
        digits.append(d)
        self.init(digits)
    }

    public var description: String {
        var result = ""
        let parts = self.map { String($0, radix: 16, uppercase: true) }
        var first = true
        for part in parts.reverse() {
            let zeroes = 2 * sizeof(Digit) - part.characters.count
            if !first && zeroes > 0 {
                // Insert leading zeroes for mid-digits
                result += String(count: zeroes, repeatedValue: "0" as Character)
            }
            first = false
            result += part
        }
        return result.isEmpty ? "0" : result
    }
}

//MARK: Low and High

extension BigUInt {
    internal var split: (high: BigUInt, low: BigUInt) {
        precondition(count > 1)
        let mid = _start + count / 2
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

public func ==(a: BigUInt, b: BigUInt) -> Bool {
    return BigUInt.compare(a, b) == .OrderedSame
}
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

//MARK: Bitwise negation

public prefix func ~(a: BigUInt) -> BigUInt {
    return BigUInt(a.map { ~$0 })
}

//MARK: Addition

extension BigUInt {
    public mutating func addInPlace(b: BigUInt, shift: Int = 0) {
        lift()
        let c = max(count, b.count)
        var carry = false
        for i in 0..<c {
            let ai = shift + i
            let (d, c) = Digit.addWithOverflow(self[ai], b[i])
            if carry {
                let (d2, c2) = Digit.addWithOverflow(d, 1)
                self[ai] = d2
                carry = c || c2
            }
            else {
                self[ai] = d
                carry = c
            }
        }
        if carry {
            self[c] = 1
        }
    }

    @warn_unused_result
    public func add(b: BigUInt, shift: Int = 0) -> BigUInt {
        var r = self
        r.addInPlace(b, shift: shift)
        return r
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
    public mutating func subtractInPlaceWithOverflow(b: BigUInt, shift: Int = 0) -> Bool {
        lift()
        let c = max(count, b.count)
        var carry = false
        for i in (0..<c) {
            let ai = shift + i
            let (d, c) = Digit.subtractWithOverflow(self[ai], b[i])
            if carry {
                let (d2, c2) = Digit.subtractWithOverflow(d, 1)
                self[ai] = d2
                carry = c || c2
            }
            else {
                self[ai] = d
                carry = c
            }
        }
        shrink()
        return carry
    }

    public mutating func subtractInPlace(b: BigUInt, shift: Int = 0) {
        let overflow = subtractInPlaceWithOverflow(b, shift: shift)
        precondition(!overflow)
    }

    @warn_unused_result
    public func subtractWithOverflow(b: BigUInt, shift: Int = 0) -> (BigUInt, Bool) {
        var result = self
        let overflow = result.subtractInPlaceWithOverflow(b, shift: shift)
        return (result, overflow)
    }

    @warn_unused_result
    public func subtract(b: BigUInt, shift: Int = 0) -> BigUInt {
        var result = self
        result.subtractInPlace(b, shift: shift)
        return result
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
}

@warn_unused_result
public func *(x: BigUInt, y: BigUInt) -> BigUInt {
    let xc = x.count
    let yc = y.count
    if xc == 0 { return BigUInt() }
    if yc == 0 { return BigUInt() }
    if yc == 1 { return x.multiplyByDigit(y[0]) }
    if xc == 1 { return y.multiplyByDigit(x[0]) }

    if yc < xc {
        let (xh, xl) = x.split
        var r = xl * y
        r.addInPlace(xh * y, shift: xc / 2)
        return r
    }
    else if xc < yc {
        let (yh, yl) = y.split
        var r = yl * x
        r.addInPlace(yh * x, shift: yc / 2)
        return r
    }

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
    r.addInPlace(high, shift: xc)
    r.addInPlace(low, shift: xc / 2)
    r.addInPlace(high, shift: xc / 2)
    if xp == yp {
        r.subtractInPlace(m, shift: xc / 2)
    }
    else {
        r.addInPlace(m, shift: xc / 2)
    }
    return r
}

public func *=(inout a: BigUInt, b: BigUInt) {
    a = a * b
}


