//
//  BigUInt Square Root.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

//MARK: Square Root

/// Returns the integer square root of a big integer; i.e., the largest integer whose square isn't greater than `value`.
///
/// - Returns: floor(sqrt(value))
public func sqrt(_ value: BigUInt) -> BigUInt {
    // This implementation uses Newton's method.
    guard !value.isZero else { return BigUInt() }
    var x = BigUInt(1) << ((value.width + 1) / 2)
    while true {
        let y = (x + value / x) >> 1
        if x == y || x == y - 1 { break }
        x = y
    }
    return x
}

