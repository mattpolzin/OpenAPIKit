// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAPI",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "OpenAPI",
            targets: ["OpenAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mattpolzin/Poly.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/mattpolzin/Sampleable.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "OpenAPI",
            dependencies: ["Poly", "Sampleable", "AnyCodable"]),
        .testTarget(
            name: "OpenAPITests",
            dependencies: ["OpenAPI"]),
    ]
)
