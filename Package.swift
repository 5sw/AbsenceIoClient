// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AbsenceIoClient",
    platforms: [
        // TODO: Xcode 13.2 set targets where backport available
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(            name: "AbsenceIoClient",            targets: ["AbsenceIoClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/5sw/AsyncBackports", branch: "main"),
        .package(url: "https://github.com/5sw/SwiftHawk", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AbsenceIoClient",
            dependencies: ["AsyncBackports", "SwiftHawk"]),
        .testTarget(
            name: "AbsenceIoClientTests",
            dependencies: ["AbsenceIoClient"]),
    ]
)
