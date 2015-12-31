//
//  Digits.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

#if TinyDigits
    public typealias Digit = UIntMax
//    public typealias Digit = UInt8
#else
    public typealias Digit = UIntMax
#endif

public protocol ShiftOperationsType {
    @warn_unused_result
    func <<(a: Self, b: Self) -> Self

    @warn_unused_result
    func >>(a: Self, b: Self) -> Self

    func <<=(inout a: Self, b: Self)
    func >>=(inout a: Self, b: Self)
}

public protocol BigDigit: UnsignedIntegerType, BitwiseOperationsType, ShiftOperationsType {
    init(_ v: Int)
    static func fromUIntMax(i: UIntMax) -> [Self]

    static func fullMultiply(x: Self, _ y: Self) -> (high: Self, low: Self)
    static func fullDivide(xh: Self, _ xl: Self, _ y: Self) -> (div: Self, mod: Self)

    static var width: Int { get }
}

extension BigDigit {
    var upshifted: Self { return self << (Self(Self.width) / 2) }
}

extension UIntMax: BigDigit {
    public static func fromUIntMax(i: UIntMax) -> [UIntMax] {
        return [i]
    }
}

extension UInt8 {
    public static func fromUIntMax(i: UIntMax) -> [UInt8] {
        var digits = Array<UInt8>()
        var remaining = i
        var width = remaining.width
        while width >= 8 {
            digits.append(UInt8(remaining & UIntMax(UInt8.max)))
            remaining >>= 8
            width -= 8
        }
        digits.append(UInt8(remaining))
        return digits
    }
}

//MARK: Digit multiplication

extension Digit {
    public static var width: Int { return 8 * sizeof(Digit) }

    /// Return a tuple with the high and low digits of the product of `x` and `y`.
    @warn_unused_result
    public static func fullMultiply(x: Digit, _ y: Digit) -> (high: Digit, low: Digit) {
        let (a, b) = x.split
        let (c, d) = y.split

        // We don't have a full-width multiplication, so we build it out of four half-width multiplications.
        // x * y = ac * HH + (ad + bc) * H + bd where H = 2^(n/2)
        let (mv, mo) = Digit.addWithOverflow(a * d, b * c)
        let (low, lo) = Digit.addWithOverflow(b * d, mv.low.upshifted)
        let high = a * c + mv.high + (mo ? Digit(1).upshifted : 0) + (lo ? 1 : 0)
        return (high, low)
    }

    private init(high: Digit, low: Digit) {
        assert(low.high == 0 && high.high == 0)
        self = high.upshifted | low
    }

    /// Divide the two-digit number `(u1, u0)` by a single digit `v` and return the quotient and remainder.
    /// - Requires: `u1 < v`, so that the result will fit in a single digit.
    /// - Complexity: O(1) with 2 divisions, 6 multiplications and ~12 or so additions/subtractions.
    @warn_unused_result
    public static func fullDivide(u1: Digit, _ u0: Digit, _ v: Digit) -> (div: Digit, mod: Digit) {
        // Division is complicated; doing it with single-digit operations is maddeningly complicated.
        // This is a Swift adaptation for "divlu2" in Hacker's Delight,
        // which is in turn a C adaptation of Knuth's Algorithm D (TAOCP vol 2, 4.3.1).
        precondition(u1 < v)

        /// Find the half-digit quotient in `(uh, ul) / vn`, which must be normalized.
        /// - Requires: uh < vn && ul.high == 0 && vn.width = width(Digit)
        func quotient(uh: Digit, _ ul: Digit, _ vn: Digit) -> Digit {
            let (vn1, vn0) = vn.split
            let q = uh / vn1 // Approximated quotient.
            let r = uh - q * vn1 // Remainder, less than vn1
            let p = q * vn0
            // q is often already correct, but sometimes the approximation overshoots by at most 2.
            // The code that follows checks for this while being careful to only perform single-digit operations.
            if q.high == 0 && p <= r.upshifted | ul { return q }
            if (r + vn1).high != 0 { return q - 1 }
            if (q - 1).high == 0 && (p - vn0) <= Digit(high: r + vn1, low: ul) { return q - 1 }
            assert((r + 2 * vn1).high != 0 || p - 2 * vn0 <= Digit(high: r + 2 * vn1, low: ul))
            return q - 2
        }
        /// Divide 3 half-digits by 2 half-digits to get a half-digit quotient and a full-digit remainder.
        /// - Requires: uh < vn && ul.high == 0 && vn.width = width(Digit)
        func divmod(uh: Digit, _ ul: Digit, _ v: Digit) -> (div: Digit, mod: Digit) {
            let q = quotient(uh, ul, v)
            // Note that `uh.low` masks off a couple of bits, and `q * v` and the
            // subtraction are likely to overflow. Despite this, the end result (remainder) will
            // still be correct and it will fit inside a single (full) Digit.
            let r = Digit(high: uh.low, low: ul) &- q &* v
            assert(r < v)
            return (q, r)
        }

        // Normalize u and v such that v has no leading zeroes.
        let w = Digit(v.width) // width of v
        let z = Digit(Digit.width) - w // number of leading zeroes in v
        let vn = v << z

        let un32 = (z == 0 ? u1 : (u1 << z) | (u0 >> w)) // No bits are lost
        let un10 = u0 << z
        let (un1, un0) = un10.split

        // Divide `(un32,un10)` by `vn`, splitting the full 4/2 division into two 3/2 ones.
        let (q1, un21) = divmod(un32, un1, vn)
        let (q0, rn) = divmod(un21, un0, vn)

        // Undo normalization of the remainder and combine the two halves of the quotient.
        let mod = rn >> z
        let div = Digit(high: q1, low: q0)
        return (div, mod)
    }
}
