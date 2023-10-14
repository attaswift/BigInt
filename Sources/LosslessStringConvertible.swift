//
//  LosslessStringConvertible.swift
//  BigInt
//
//  Created by Milkhail Babushkin on 14.10.2023.
//  Copyright © 2023 Károly Lőrentey. All rights reserved.
//

extension BigUInt: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(stringLiteral: description)
    }
}

extension BigInt: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(stringLiteral: description)
    }
}
