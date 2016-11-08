//
//  BigUInt Shifts.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

extension BigUInt {

    //MARK: Shift Operators

    /// Shift a big integer to the right by `amount` bits and store the result in place.
    ///
    /// - Complexity: O(count)
    public static func <<= (b: inout BigUInt, amount: Int) {
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
            b._digits.insert(contentsOf: Array<Digit>(repeating: 0, count: ext), at: 0)
            b._end = b._digits.count
        }
    }

    /// Shift a big integer to the left by `amount` bits and return the result.
    ///
    /// - Returns: b * 2^amount
    /// - Complexity: O(count)
    public static func << (b: BigUInt, amount: Int) -> BigUInt {
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

    /// Shift a big integer to the right by `amount` bits and store the result in place.
    ///
    /// - Complexity: O(count)
    public static func >>= (b: inout BigUInt, amount: Int) {
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
            b._digits.removeSubrange(0 ..< ext)
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

    /// Shift a big integer to the right by `amount` bits and return the result.
    ///
    /// - Returns: b / 2^amount
    /// - Complexity: O(count)
    public static func >> (b: BigUInt, amount: Int) -> BigUInt {
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
            for i in (ext..<b.count).reversed() {
                let digit = b[i]
                result[i - ext] = highbits | digit >> down
                highbits = digit << up
            }
        }
        else {
            for i in (ext..<b.count).reversed() {
                result[i - ext] = b[i]
            }
        }
        return result
    }
}
