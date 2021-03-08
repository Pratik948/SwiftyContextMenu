// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyContextMenu",
    platforms: [SupportedPlatform.iOS(SupportedPlatform.IOSVersion.v10)],
    products: [
        .library(
            name: "SwiftyContextMenu",
            targets: ["SwiftyContextMenu"]),
    ],
    targets: [
        .target(
            name: "SwiftyContextMenu",
            dependencies: []),
    ]
)
