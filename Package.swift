// swift-tools-version:5.9
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
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4),
        .macCatalyst(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "BigInt", targets: ["BigInt"])
    ], 
    targets: [
        .target(name: "BigInt", path: "Sources"),
        .testTarget(name: "BigIntTests", dependencies: ["BigInt"], path: "Tests")
    ]
)
