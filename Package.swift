// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "Compression", products: [
    .library(name: "Compression", targets: ["Compression"]),
], dependencies: [
    .package(url: "https://github.com/purpln/zlib.git", branch: "main"),
], targets: [
    .target(name: "Compression", dependencies: [
        .product(name: "zlib", package: "zlib"),
    ]),
])
