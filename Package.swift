// swift-tools-version:6.3
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
        .library(name: "SwiftBigInt", targets: ["SwiftBigInt"])
    ],
    targets: [
        .target(
            name: "SwiftBigInt", path: "Sources",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
        .testTarget(
            name: "BigIntTests", dependencies: ["SwiftBigInt"], path: "Tests",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
    ]
)
