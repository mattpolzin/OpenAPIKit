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
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"), // just for tests
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.14.0") // just for tests
    ],
    targets: [
        .target(
            name: "OpenAPIKit",
            dependencies: []),
        .testTarget(
            name: "OpenAPIKitTests",
            dependencies: ["OpenAPIKit", "Yams", "FineJSON"]),
        .testTarget(
            name: "OpenAPIKitCompatibilitySuite",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "OpenAPIKitErrorReportingTests",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "EitherTests",
            dependencies: ["OpenAPIKit"]),
        .testTarget(
            name: "OrderedDictionaryTests",
            dependencies: ["OpenAPIKit", "Yams", "FineJSON"]),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["OpenAPIKit"])
    ],
    swiftLanguageVersions: [ .v5 ]
)
