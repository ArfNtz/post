// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "post",
    products: [
        .library(name: "post", targets: ["post"]),
        .executable(name: "filepost", targets: ["filepost"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "post",
            dependencies: ["NIO", "NIOHTTP1", "NIOSSL", "NIOFoundationCompat"]),
        .target(
            name: "filepost",
            dependencies: ["post"]),

        .testTarget(
            name: "postTests",
            dependencies: ["post"]),
    ]
)
