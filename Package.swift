//
//  Package.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-12.
//  Copyright © 2016 Károly Lőrentey.
//

import PackageDescription

let package = Package(
    name: "BigInt",
    dependencies: [
        .Package(url: "https://github.com/lorentey/SipHash", majorVersion: 1, minor: 0)
    ]
)
