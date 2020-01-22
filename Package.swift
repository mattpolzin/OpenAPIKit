// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAPIKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OpenAPIKit",
            targets: ["OpenAPIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mattpolzin/Poly.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/mattpolzin/Sampleable.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", .upToNextMinor(from: "0.2.2")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"), // just for tests
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.14.0") // just for tests
    ],
    targets: [
        .target(
            name: "OpenAPIKit",
            dependencies: ["Poly", "Sampleable", "AnyCodable"]),
        .testTarget(
            name: "OpenAPIKitTests",
            dependencies: ["OpenAPIKit", "Yams", "FineJSON"]),
    ],
    swiftLanguageVersions: [ .v5 ]
)
