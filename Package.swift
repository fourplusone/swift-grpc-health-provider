// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-grpc-health-provider",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "HealthProvider",
            targets: ["HealthProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.12"),
    ],
    targets: [
        .target(
            name: "HealthProvider",
            dependencies: [.product(name: "GRPC", package: "grpc-swift"),]),
        .testTarget(
            name: "HealthProviderTests",
            dependencies: ["HealthProvider"]),
    ]
)
