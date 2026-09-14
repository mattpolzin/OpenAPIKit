// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "OpenAPIKit-Project",
    platforms: [
        .macOS("26.4")
    ],
    products: [
        .executable(name: "OpenAPIKit-Project", targets: ["OpenAPIKit-Project"])
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "OpenAPIKit-Project",
            dependencies: [
                .product(name: "OpenAPIKit", package: "OpenAPIKit")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
