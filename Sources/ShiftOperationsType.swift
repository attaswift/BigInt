//
//  ShiftOperationsType.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

// This protocol is missing from stdlib for some reason.

public protocol ShiftOperationsType {
    @warn_unused_result
    func <<(a: Self, b: Self) -> Self

    @warn_unused_result
    func >>(a: Self, b: Self) -> Self

    func <<=(inout a: Self, b: Self)
    func >>=(inout a: Self, b: Self)
}

