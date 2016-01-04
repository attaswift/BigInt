//
//  BigUInt Multiplication.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

extension BigUInt {

    //MARK: Multiplication

    /// Multiply this big integer by a single digit, and store the result in place of the original big integer.
    ///
    /// - Complexity: O(count)
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

    /// Multiply this big integer by a single digit, and return the result.
    ///
    /// - Complexity: O(count)
    @warn_unused_result
    public func multiplyByDigit(y: Digit) -> BigUInt {
        var r = self
        r.multiplyInPlaceByDigit(y)
        return r
    }

    /// Multiply `x` by `y`, and add the result to this integer, optionally shifted `shift` digits to the left.
    ///
    /// - Note: This is the fused multiply/shift/add operation; it is more efficient than doing the components
    ///   individually. (The fused operation doesn't need to allocate space for temporary big integers.)
    /// - Returns: `self` is set to `self + (x * y) << (shift * 2^Digit.width)`
    /// - Complexity: O(count)
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

    /// Multiply this integer by `y` and return the result.
    ///
    /// - Note: This uses the naive O(n^2) multiplication algorithm unless both arguments have more than
    ///   `BigUInt.directMultiplicationLimit` digits.
    /// - Complexity: O(n^log2(3))
    @warn_unused_result
    public func multiply(y: BigUInt) -> BigUInt {
        // This method is mostly defined for symmetry with the rest of the arithmetic operations.
        return self * y
    }

    /// Multiplication switches to an asymptotically better recursive algorithm when arguments have more digits than this limit.
    public static var directMultiplicationLimit: Int = 1024
}

//MARK: Multiplication

/// Multiply `a` by `b` and return the result.
///
/// - Note: This uses the naive O(n^2) multiplication algorithm unless both arguments have more than
///   `BigUInt.directMultiplicationLimit` digits.
/// - Complexity: O(n^log2(3))
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
        r.addInPlace(xh * y, shift: x.middleIndex)
        return r
    }
    else if xc < yc {
        let (yh, yl) = y.split
        var r = yl * x
        r.addInPlace(yh * x, shift: y.middleIndex)
        return r
    }

    let shift = x.middleIndex

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

/// Multiply `a` by `b` and store the result in `a`.
public func *=(inout a: BigUInt, b: BigUInt) {
    a = a * b
}

