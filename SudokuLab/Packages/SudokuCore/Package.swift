// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SudokuCore",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "SudokuCore",
            targets: ["SudokuCore"]
        )
    ],
    targets: [
        .target(name: "SudokuCore")
    ]
)
