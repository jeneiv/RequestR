// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RequestR",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v12),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RequestR",
            targets: ["RequestR"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RequestR",
            path: "Sources/RequestR"
        ),
        .target(
            name: "RequestRMocking",
            path: "Sources/RequestRMocking"
        ),
        .testTarget(
            name: "RequestRTests",
            dependencies: ["RequestR", "RequestRMocking"]
        ),
    ]
)
