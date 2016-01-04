//
//  BigUInt Comparison.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

extension BigUInt: Comparable {
    //MARK: Comparison
    
    /// Compare `a` to `b` and return an `NSComparisonResult` indicating their order.
    @warn_unused_result
    public static func compare(a: BigUInt, _ b: BigUInt) -> NSComparisonResult {
        if a.count != b.count { return a.count > b.count ? .OrderedDescending : .OrderedAscending }
        for i in (0..<a.count).reverse() {
            let ad = a[i]
            let bd = b[i]
            if ad != bd { return ad > bd ? .OrderedDescending : .OrderedAscending }
        }
        return .OrderedSame
    }
}

//MARK: Comparison

@warn_unused_result
public func ==(a: BigUInt, b: BigUInt) -> Bool {
    return BigUInt.compare(a, b) == .OrderedSame
}
@warn_unused_result
public func <(a: BigUInt, b: BigUInt) -> Bool {
    return BigUInt.compare(a, b) == .OrderedAscending
}

extension BigUInt {
    /// Return true iff this integer is zero.
    ///
    /// - Complexity: O(1)
    var isZero: Bool {
        return count == 0
    }
}

