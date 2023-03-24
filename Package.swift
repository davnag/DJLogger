// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DJLogger",
    platforms: [
        .iOS(.v15),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "DJLogger",
            targets: ["DJLogger"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DJLogger",
            dependencies: []),
        .testTarget(
            name: "DJLoggerTests",
            dependencies: ["DJLogger"]),
    ]
)
