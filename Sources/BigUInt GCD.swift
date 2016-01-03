//
//  BigUInt GCD.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

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
}