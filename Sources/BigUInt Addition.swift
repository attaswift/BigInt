//
//  BigUInt Addition.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

extension BigUInt {
    //MARK: Addition
    
    /// Add the digit `d` to this integer in place.
    /// `d` is shifted `shift` digits to the left before being added.
    ///
    /// - Complexity: O(max(count, shift))
    public mutating func addDigit(_ d: Digit, atPosition shift: Int = 0) {
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

    /// Add the digit `d` to this integer and return the result.
    /// `d` is shifted `shift` digits to the left before being added.
    ///
    /// - Complexity: O(max(count, shift))
    public func addingDigit(_ d: Digit, atPosition shift: Int = 0) -> BigUInt {
        var r = self
        r.addDigit(d, atPosition: shift)
        return r
    }

    /// Add `b` to this integer in place.
    /// `b` is shifted `shift` digits to the left before being added.
    ///
    /// - Complexity: O(max(count, b.count + shift))
    public mutating func add(_ b: BigUInt, atPosition shift: Int = 0) {
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

    /// Add `b` to this integer and return the result.
    /// `b` is shifted `shift` digits to the left before being added.
    ///
    /// - Complexity: O(max(count, b.count + shift))
    public func adding(_ b: BigUInt, atPosition shift: Int = 0) -> BigUInt {
        var r = self
        r.add(b, atPosition: shift)
        return r
    }

    /// Increment this integer by one. If `shift` is non-zero, it selects
    /// the digit that is to be incremented.
    ///
    /// - Complexity: O(count + shift)
    public mutating func increment(atPosition shift: Int = 0) {
        self.addDigit(1, atPosition: shift)
    }

    /// Add `a` and `b` together and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func +(a: BigUInt, b: BigUInt) -> BigUInt {
        return a.adding(b)
    }

    /// Add `a` and `b` together, and store the sum in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func +=(a: inout BigUInt, b: BigUInt) {
        a.add(b, atPosition: 0)
    }

    /// Add `lhs` and `rhs` together, returning the result. This function never results in an overflow.
    public static func addWithOverflow(_ lhs: BigUInt, _ rhs: BigUInt) -> (BigUInt, overflow: Bool) {
        return (lhs + rhs, false)
    }
}
