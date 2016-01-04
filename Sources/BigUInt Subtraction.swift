//
//  BigUInt Subtraction.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

extension BigUInt {
    //MARK: Subtraction

    /// Subtract a digit `d` from this integer in place, returning a flag that is true if the operation
    /// caused an arithmetic overflow. `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Note: If the result is true, then `self` becomes the two's complement of the absolute difference.
    /// - Complexity: O(count)
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

    /// Subtract a digit `d` from this integer, returning the difference and a flag that is true if the operation
    /// caused an arithmetic overflow. `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Note: If `overflow` is true, then the returned value is the two's complement of the absolute difference.
    /// - Complexity: O(count)
    @warn_unused_result
    public func subtractDigitWithOverflow(d: Digit, shift: Int = 0) -> (BigUInt, overflow: Bool) {
        var result = self
        let overflow = result.subtractDigitInPlaceWithOverflow(d, shift: shift)
        return (result, overflow)
    }

    /// Subtract a digit `d` from this integer in place.
    /// `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= d * 2^shift
    /// - Complexity: O(count)
    public mutating func subtractDigitInPlace(d: Digit, shift: Int = 0) {
        let overflow = subtractDigitInPlaceWithOverflow(d, shift: shift)
        precondition(!overflow)
    }

    /// Subtract a digit `d` from this integer and return the result.
    /// `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= d * 2^shift
    /// - Complexity: O(count)
    @warn_unused_result
    public func subtractDigit(d: Digit, shift: Int = 0) -> BigUInt {
        var result = self
        result.subtractDigitInPlace(d, shift: shift)
        return result
    }

    /// Subtract `b` from this integer in place, and return true iff the operation caused an
    /// arithmetic overflow. `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Note: If the result is true, then `self` becomes the twos' complement of the absolute difference.
    /// - Complexity: O(count)
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

    /// Subtract `b` from this integer, returning the difference and a flag that is true if the operation caused an
    /// arithmetic overflow. `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Note: If `overflow` is true, then the result value is the twos' complement of the absolute value of the difference.
    /// - Complexity: O(count)
    @warn_unused_result
    public func subtractWithOverflow(b: BigUInt, shift: Int = 0) -> (BigUInt, overflow: Bool) {
        var result = self
        let overflow = result.subtractInPlaceWithOverflow(b, shift: shift)
        return (result, overflow)
    }

    /// Subtract `b` from this integer in place.
    /// `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= b * 2^shift
    /// - Complexity: O(count)
    public mutating func subtractInPlace(b: BigUInt, shift: Int = 0) {
        let overflow = subtractInPlaceWithOverflow(b, shift: shift)
        precondition(!overflow)
    }

    /// Subtract `b` from this integer, and return the difference.
    /// `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= b * 2^shift
    /// - Complexity: O(count)
    @warn_unused_result
    public func subtract(b: BigUInt, shift: Int = 0) -> BigUInt {
        var result = self
        result.subtractInPlace(b, shift: shift)
        return result
    }

    /// Decrement this integer by one.
    ///
    /// - Requires: !isZero
    /// - Complexity: O(count)
    public mutating func decrement(shift shift: Int = 0) {
        self.subtractDigitInPlace(1, shift: shift)
    }
}

//MARK: Subtraction

/// Subtract `b` from `a` and return the result.
///
/// - Requires: a >= b
/// - Complexity: O(a.count)
@warn_unused_result
public func -(a: BigUInt, b: BigUInt) -> BigUInt {
    return a.subtract(b)
}

/// Subtract `b` from `a` and store the result in `a`.
///
/// - Requires: a >= b
/// - Complexity: O(a.count)
public func -=(inout a: BigUInt, b: BigUInt) {
    a.subtractInPlace(b, shift: 0)
}
