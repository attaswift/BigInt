//
//  GCD.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016-2017 Károly Lőrentey.
//

extension BigUInt {
    //MARK: Greatest Common Divisor
    
    /// Returns the greatest common divisor of `self` and `b`.
    ///
    /// - Complexity: O(count^2) where count = max(self.count, b.count)
    public func greatestCommonDivisor(with b: BigUInt) -> BigUInt {
        // This is Stein's algorithm: https://en.wikipedia.org/wiki/Binary_GCD_algorithm
        if self.isZero { return b }
        if b.isZero { return self }

        let az = self.trailingZeroBitCount
        let bz = b.trailingZeroBitCount
        let twos = Swift.min(az, bz)

        var (x, y) = (self >> az, b >> bz)
        if x < y { swap(&x, &y) }

        while !x.isZero {
            x >>= x.trailingZeroBitCount
            if x < y { swap(&x, &y) }
            x -= y
        }
        return y << twos
    }
    
    /// Returns the [multiplicative inverse of this integer in modulo `modulus` arithmetic][inverse],
    /// or `nil` if there is no such number.
    /// 
    /// [inverse]: https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Modular_integers
    ///
    /// - Returns: If `gcd(self, modulus) == 1`, the value returned is an integer `a < modulus` such that `(a * self) % modulus == 1`. If `self` and `modulus` aren't coprime, the return value is `nil`.
    /// - Complexity: O(count^3)
    public func inverse(_ modulus: BigUInt) -> BigUInt? {
        var t1 = BigInt(0)
        var t2 = BigInt(1)
        var r1 = modulus
        var r2 = self
        while !r2.isZero {
            let quotient = r1 / r2
            (t1, t2) = (t2, t1 - BigInt(quotient) * t2)
            (r1, r2) = (r2, r1 - quotient * r2)
        }
        if r1 > 1 { return nil }
        if t1.sign == .minus { return modulus - t1.magnitude }
        return t1.magnitude
    }
}
