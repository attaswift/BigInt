//
//  ShiftOperations.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

// This protocol is missing from stdlib for some reason.

/// Describes a type that supports all the standard shift operators.
public protocol ShiftOperations {
    /// Shift the value `a` by `b` bits to the left and return the result.
    static func <<(a: Self, b: Self) -> Self

    /// Shift the value `a` by `b` bits to the right and return the result.
    static func >>(a: Self, b: Self) -> Self

    /// Shift the value `a` by `b` bits to the left and store the result in `a`.
    static func <<=(a: inout Self, b: Self)

    /// Shift the value `a` by `b` bits to the right and store the result in `a`.
    static func >>=(a: inout Self, b: Self)
}

