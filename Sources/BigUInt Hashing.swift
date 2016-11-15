//
//  BigUInt Hashing.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

import SipHash

extension BigUInt: SipHashable {
    //MARK: Hashing

    /// Append this `BigUInt` to the specified hasher.
    public func appendHashes(to hasher: inout SipHasher) {
        for i in 0 ..< count {
            hasher.append(self[i])
        }
    }
}
