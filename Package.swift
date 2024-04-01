// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPolyglot",
    products: [
        .executable(name: "swiftpolyglot", targets: ["SwiftPolyglot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.3.1")),
    ],
    targets: [
        .executableTarget(
            name: "SwiftPolyglot",
            dependencies: [
                "SwiftPolyglotCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(name: "SwiftPolyglotCore"),
        .testTarget(
            name: "SwiftPolyglotCoreTests",
            dependencies: ["SwiftPolyglotCore"],
            resources: [
                .copy("TestFiles"),
            ]
        ),
    ]
)
