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
    internal var _level: Int
    internal var _offset: Int

    internal init(digits: [Digit], level: Int, offset: Int) {
        self._digits = digits
        self._level = level
        self._offset = offset
    }
}

//MARK: Initializers

extension BigUInt {
    public init() {
        self._digits = []
        self._level = 0
        self._offset = 0
    }

    internal init(_ digits: [Digit]) {
        var digits = digits
        digits.shrink()
        let level = (digits.count > 0 ? UInt(digits.count - 1).rank + 1 : 0)
        self.init(digits: digits, level: level, offset: 0)
    }

    internal init(_ value: BigUInt) {
        self = value
        uniq()
    }

    internal init(_ value: DigitsSlice) {
        self.init(Array(value))
    }
}

extension BigUInt: IntegerLiteralConvertible {
    public init(integerLiteral value: UInt64) {
        self.init(value.toUIntMax())
    }

    public init<I: UnsignedIntegerType>(_ integer: I) {
        var digits = Array<Digit>()
        var remaining = integer.toUIntMax()
        var rank = remaining.rank
        let chunk = 8 * sizeof(Digit)
        while rank >= chunk {
            digits.append(Digit(remaining & UIntMax(Digit.max)))
            remaining >>= UIntMax(chunk)
            rank -= chunk
        }
        digits.append(Digit(remaining))
        self.init(digits)
    }
}

//MARK: Shrink and extend

extension BigUInt {
    internal mutating func shrink() {
        uniq()
        guard _digits.last == 0 else { return }
        repeat { _digits.removeLast() } while _digits.last == 0
        _level = (_digits.count > 0 ? UInt(_digits.count - 1).rank + 1 : 0)
    }

    internal mutating func extend(index: Int) {
        uniq()
        let i = _start + index
        guard i > _digits.count - 1 else { return }
        _digits += Array(count: i - (_digits.count - 1), repeatedValue: 0)
        _level = (_digits.count > 0 ? UInt(_digits.count - 1).rank + 1 : 0)
    }

    internal var isSlice: Bool { return _offset > 0 || count < _digits.count }
    internal mutating func uniq() {
        guard isSlice else { return }
        self._digits = Array(self)
        self._offset = 0
    }
}

//MARK: CollectionType

extension BigUInt: CollectionType {
    public var count: Int {
        guard _level > 0 else { return 0 }
        return 1 << (_level - 1)
    }

    public var startIndex: Int { return 0 }
    public var endIndex: Int { return count }

    internal var _start: Int {
        return _offset * count
    }
    internal var _end: Int {
        return (_offset + 1) * count
    }

    public func generate() -> DigitsGenerator {
        return DigitsGenerator(digits: _digits, endIndex: endIndex, index: startIndex)
    }

    public subscript(index: Int) -> Digit {
        get {
            return (_start + index < _digits.count ? _digits[_start + index] : 0)
        }
        set(digit) {
            uniq()
            let i = _start + index
            if i < _digits.count {
                _digits[i] = digit
                if digit == 0 && i == _digits.count - 1 {
                    shrink()
                }
            }
            else {
                guard digit != 0 else { return }
                extend(index)
                _digits[i] = digit
            }
        }
    }

    public subscript(range: Range<Int>) -> DigitsSlice {
        get {
            let start = _start
            return DigitsSlice(
                digits: _digits,
                start: start + range.startIndex,
                end: start + range.endIndex)
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
        return self[startIndex..<endIndex].description
    }
}

//MARK: Generator

public struct DigitsGenerator: GeneratorType {
    internal let digits: [Digit]
    internal let endIndex: Int
    internal var index: Int

    public mutating func next() -> Digit? {
        guard index < endIndex else { return nil }
        let v = (index < digits.count ? digits[index] : 0)
        index += 1
        return v
    }
}

//MARK: DigitsSlice

public struct DigitsSlice: CollectionType {
    internal var digits: [Digit]
    internal let start: Int
    internal let end: Int

    public var count: Int { return end - start }
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return count }

    public func generate() -> DigitsGenerator {
        return DigitsGenerator(digits: digits, endIndex: end, index: start)
    }

    public subscript(index: Int) -> Digit {
        get {
            precondition(index >= 0)
            let i = start + index
            return i < digits.count ? digits[i] : 0
        }
    }
}

extension DigitsSlice: CustomStringConvertible {
    public var description: String {
        var result = ""
        let parts = self[0..<count].map { String($0, radix: 16, uppercase: true) }
        var first = true
        for part in parts.reverse() {
            if first && part == "0" { continue }
            let zeroes = 2 * sizeof(Digit) - part.characters.count
            if !first && zeroes > 0 {
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
    /// Returns the low-order half of this BigUInt.
    internal var low: BigUInt {
        return BigUInt(digits: _digits, level: _level - 1, offset: 2 * _offset)
    }

    /// Returns the high-order half of this BigUInt.
    internal var high: BigUInt {
        return BigUInt(digits: _digits, level: _level - 1, offset: 2 * _offset + 1)
    }

    internal var split: (high: BigUInt, low: BigUInt) { return (high, low) }
}

//MARK: Comparable

extension BigUInt: Comparable {
}

public func ==(a: BigUInt, b: BigUInt) -> Bool {
    let c = max(a.count, b.count)
    for i in (0..<c) {
        let ad = a[i]
        let bd = b[i]
        if ad != bd { return false }
    }
    return true
}

public func <(a: BigUInt, b: BigUInt) -> Bool {
    let c = max(a.count, b.count)
    for i in (0..<c).reverse() {
        let ad = a[i]
        let bd = b[i]
        if ad != bd { return ad < bd }
    }
    return false
}

extension BigUInt {
    var isZero: Bool {
        return self.indexOf { $0 != 0 } == nil
    }
}



//MARK: Bitwise negation

public prefix func ~(a: BigUInt) -> BigUInt {
    return BigUInt(a.map { ~$0 })
}

//MARK: Addition

extension BigUInt {

    public mutating func add(b: BigUInt, shift: Int = 0) {
        uniq()
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
        _level = (_digits.count > 0 ? UInt(_digits.count - 1).rank + 1 : 0)
    }
}

@warn_unused_result
public func +(a: BigUInt, b: BigUInt) -> BigUInt {
    var result = a
    result.add(b)
    return result
}

//MARK: Subtraction

extension BigUInt {
    @warn_unused_result
    public mutating func subtractWithOverflow(b: BigUInt, shift: Int = 0) -> Bool {
        uniq()
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
        return carry
    }

    public mutating func subtract(b: BigUInt, shift: Int = 0) {
        let overflow = subtractWithOverflow(b, shift: shift)
        precondition(!overflow)
    }
}

@warn_unused_result
public func -(a: BigUInt, b: BigUInt) -> BigUInt {
    var result = a
    result.subtract(b)
    return result
}

//MARK: Multiplication

extension BigUInt {
    @warn_unused_result
    public func scalarMultiply(y: Digit) -> BigUInt {
        var result = BigUInt()
        var carry: Digit = 0
        let c = self.count
        for i in 0..<c {
            let (h, l) = Digit.fullMultiply(self[i], y)
            let (low, o) = Digit.addWithOverflow(l, carry)
            result[i] = low
            carry = (o ? h + 1 : h)
        }
        result[c] = carry
        return result
    }
}

@warn_unused_result
public func *(x: BigUInt, y: BigUInt) -> BigUInt {
    let xc = x.count
    let yc = y.count
    if xc == 0 { return BigUInt() }
    if yc == 0 { return BigUInt() }
    if yc == 1 { return x.scalarMultiply(y[0]) }
    if xc == 1 { return y.scalarMultiply(x[0]) }

    if yc < xc {
        let (xh, xl) = x.split
        var r = xl * y
        r.add(xh * y, shift: xc / 2)
        return r
    }
    else if xc < yc {
        let (yh, yl) = y.split
        var r = yl * x
        r.add(yh * x, shift: yc / 2)
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
    r.add(high, shift: xc)
    r.add(low, shift: xc / 2)
    r.add(high, shift: xc / 2)
    if xp == yp {
        r.subtract(m, shift: xc / 2)
    }
    else {
        r.add(m, shift: xc / 2)
    }
    return r
}


