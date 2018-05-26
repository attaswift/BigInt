// swift-tools-version:4.0
//
//  Package.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-12.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import PackageDescription

let package = Package(
    name: "BigInt",
    products: [
        .library(name: "BigInt", targets: ["BigInt"])
    ],
    dependencies: [
        // @attaswift: remove this pragma after you have fixed SipHash!
    #if os(Linux)
        .package(url: "https://github.com/dankogai/SipHash", from: "1.2.0")
    #else
        .package(url: "https://github.com/attaswift/SipHash", from: "1.2.0")
    #endif
    ],
    targets: [
        .target(name: "BigInt", dependencies: ["SipHash"], path: "sources"),
        .testTarget(name: "BigIntTests", dependencies: ["BigInt"], path: "tests")
    ],
    swiftLanguageVersions: [4]
)
