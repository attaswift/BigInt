//
//  BigUInt Subtraction.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

extension BigUInt {
    //MARK: Subtraction

    /// Subtract a digit `d` from this integer in place, returning a flag that is true if the operation
    /// caused an arithmetic overflow. `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Note: If the result is true, then `self` becomes the two's complement of the absolute difference.
    /// - Complexity: O(count)
    public mutating func subtractDigitWithOverflow(_ d: Digit, atPosition shift: Int = 0) -> Bool {
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
    public func subtractingDigitWithOverflow(_ d: Digit, atPosition shift: Int = 0) -> (BigUInt, overflow: Bool) {
        var result = self
        let overflow = result.subtractDigitWithOverflow(d, atPosition: shift)
        return (result, overflow)
    }

    /// Subtract a digit `d` from this integer in place.
    /// `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= d * 2^shift
    /// - Complexity: O(count)
    public mutating func subtractDigit(_ d: Digit, atPosition shift: Int = 0) {
        let overflow = subtractDigitWithOverflow(d, atPosition: shift)
        precondition(!overflow)
    }

    /// Subtract a digit `d` from this integer and return the result.
    /// `d` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= d * 2^shift
    /// - Complexity: O(count)
    public func subtractingDigit(_ d: Digit, atPosition shift: Int = 0) -> BigUInt {
        var result = self
        result.subtractDigit(d, atPosition: shift)
        return result
    }

    /// Subtract `b` from this integer in place, and return true iff the operation caused an
    /// arithmetic overflow. `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Note: If the result is true, then `self` becomes the twos' complement of the absolute difference.
    /// - Complexity: O(count)
    public mutating func subtractWithOverflow(_ b: BigUInt, atPosition shift: Int = 0) -> Bool {
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
    public func subtractingWithOverflow(_ b: BigUInt, atPosition shift: Int = 0) -> (BigUInt, overflow: Bool) {
        var result = self
        let overflow = result.subtractWithOverflow(b, atPosition: shift)
        return (result, overflow)
    }

    /// Subtract `b` from this integer in place.
    /// `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= b * 2^shift
    /// - Complexity: O(count)
    public mutating func subtract(_ b: BigUInt, atPosition shift: Int = 0) {
        let overflow = subtractWithOverflow(b, atPosition: shift)
        precondition(!overflow)
    }

    /// Subtract `b` from this integer, and return the difference.
    /// `b` is shifted `shift` digits to the left before being subtracted.
    ///
    /// - Requires: self >= b * 2^shift
    /// - Complexity: O(count)
    public func subtracting(_ b: BigUInt, atPosition shift: Int = 0) -> BigUInt {
        var result = self
        result.subtract(b, atPosition: shift)
        return result
    }

    /// Decrement this integer by one.
    ///
    /// - Requires: !isZero
    /// - Complexity: O(count)
    public mutating func decrement(atPosition shift: Int = 0) {
        self.subtract(1, atPosition: shift)
    }

    /// Subtract `b` from `a` and return the result.
    ///
    /// - Requires: a >= b
    /// - Complexity: O(a.count)
    public static func -(a: BigUInt, b: BigUInt) -> BigUInt {
        return a.subtracting(b)
    }

    /// Subtract `b` from `a` and store the result in `a`.
    ///
    /// - Requires: a >= b
    /// - Complexity: O(a.count)
    public static func -=(a: inout BigUInt, b: BigUInt) {
        a.subtract(b, atPosition: 0)
    }

    /// Subtracts rhs from `lhs`, returning the result and a `Bool` that is true iff the operation caused an arithmetic overflow.
    /// Overflow is returned if and only if `lhs` is less than `rhs`, in which case the result is the twos' complement of the absolute difference.
    public static func subtractWithOverflow(_ lhs: BigUInt, _ rhs: BigUInt) -> (BigUInt, overflow: Bool) {
        return lhs.subtractingWithOverflow(rhs)
    }
}
