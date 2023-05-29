// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(name: "CoreModel", targets: ["CoreModel"]),
        .library(name: "CustomViews", targets: ["CustomViews"]),
        .library(name: "Essentials", targets: ["Essentials"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Search", targets: ["Search"]),
    ],
    targets: [
        .target(name: "CoreModel"),
        .target(name: "CustomViews"),
        .target(name: "Essentials"),
        .target(name: "Networking"),
        .target(name: "Search", dependencies: ["CoreModel", "CustomViews", "Essentials", "Networking"]),
        .testTarget(name: "CoreModelTests", dependencies: ["CoreModel"]),
        .testTarget(name: "SearchTests", dependencies: ["Search"]),
    ]
)
