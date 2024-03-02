// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "OpenAPIKit",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OpenAPIKit30",
            targets: ["OpenAPIKit30"]),
        .library(
            name: "OpenAPIKit",
            targets: ["OpenAPIKit"]),
        .library(
            name: "OpenAPIKitCompat",
            targets: ["OpenAPIKitCompat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", "4.0.0"..<"6.0.0") // just for tests
    ],
    targets: [
        .target(
            name: "OpenAPIKitCore",
            dependencies: [],
            exclude: ["AnyCodable/README.md"]),
        .testTarget(
            name: "OpenAPIKitCoreTests",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "EitherTests",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OrderedDictionaryTests",
            dependencies: ["OpenAPIKitCore", "Yams"]),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["OpenAPIKitCore"]),

        .target(
            name: "OpenAPIKit30",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OpenAPIKit30Tests",
            dependencies: ["OpenAPIKit30", "Yams"]),
        .testTarget(
            name: "OpenAPIKit30RealSpecSuite",
            dependencies: ["OpenAPIKit30", "Yams"]),
        .testTarget(
            name: "OpenAPIKit30ErrorReportingTests",
            dependencies: ["OpenAPIKit30", "Yams"]),

        .target(
            name: "OpenAPIKit",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OpenAPIKitTests",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "OpenAPIKitRealSpecSuite",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "OpenAPIKitErrorReportingTests",
            dependencies: ["OpenAPIKit", "Yams"]),

        .target(
            name: "OpenAPIKitCompat",
            dependencies: ["OpenAPIKit30", "OpenAPIKit"]),
        .testTarget(
            name: "OpenAPIKitCompatTests",
            dependencies: ["OpenAPIKitCompat"])
    ],
    swiftLanguageVersions: [ .v5 ]
)
