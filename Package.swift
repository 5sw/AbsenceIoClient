// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AbsenceIoClient",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "AbsenceIoClient", targets: ["AbsenceIoClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/5sw/AsyncBackports", branch: "main"),
        .package(url: "https://github.com/5sw/SwiftHawk", from: "0.1.0")
    ],
    targets: [
        .target(name: "AbsenceIoClient", dependencies: ["AsyncBackports", "SwiftHawk"]),
        .testTarget(name: "AbsenceIoClientTests", dependencies: ["AbsenceIoClient"]),
    ]
)
