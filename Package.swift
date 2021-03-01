// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "OpenAPIKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OpenAPIKit_3_0",
            targets: ["OpenAPIKit_3_0"]),
        .library(
            name: "OpenAPIKit",
            targets: ["OpenAPIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"), // just for tests
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.14.0") // just for tests
    ],
    targets: [
        .target(
            name: "OpenAPIKitCore",
            dependencies: []),
        .testTarget(
            name: "EitherTests",
            dependencies: ["OpenAPIKit_3_0"]),
        .testTarget(
            name: "OrderedDictionaryTests",
            dependencies: ["OpenAPIKit_3_0", "Yams", "FineJSON"]),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["OpenAPIKit_3_0"]),

        .target(
            name: "OpenAPIKit_3_0",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OpenAPIKit_3_0Tests",
            dependencies: ["OpenAPIKit_3_0", "Yams", "FineJSON"]),
        .testTarget(
            name: "OpenAPIKit_3_0CompatibilitySuite",
            dependencies: ["OpenAPIKit_3_0", "Yams"]),
        .testTarget(
            name: "OpenAPIKit_3_0ErrorReportingTests",
            dependencies: ["OpenAPIKit_3_0", "Yams"]),

        .target(
            name: "OpenAPIKit",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OpenAPIKitTests",
            dependencies: ["OpenAPIKit", "Yams", "FineJSON"]),
        .testTarget(
            name: "OpenAPIKitCompatibilitySuite",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "OpenAPIKitErrorReportingTests",
            dependencies: ["OpenAPIKit", "Yams"])
    ],
    swiftLanguageVersions: [ .v5 ]
)
