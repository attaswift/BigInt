//
//  BigUInt Modular Exponentiation.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

extension BigUInt {
    //MARK: Modular Exponentiation
    
    /// Returns the remainder of `base` raised to the power `exponent` under `modulus`.
    ///
    /// - Complexity: O(exponent.count * modulus.count^2)
    @warn_unused_result
    public static func powmod(base: BigUInt, _ exponent: BigUInt, modulus: BigUInt) -> BigUInt {
        // https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
        if modulus == 1 { return 0 }
        var result = BigUInt(1)
        var b = base % modulus
        var e = exponent
        while e > 0 {
            if e[0] & 1 == 1 {
                result = (result * b) % modulus
            }
            e >>= 1
            b = (b * b) % modulus
        }
        return result
    }
}
