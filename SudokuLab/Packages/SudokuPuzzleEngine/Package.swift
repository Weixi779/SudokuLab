// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SudokuPuzzleEngine",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "SudokuPuzzleEngine",
            targets: ["SudokuPuzzleEngine"]
        )
    ],
    targets: [
        .target(name: "SudokuPuzzleEngine"),
        .testTarget(
            name: "SudokuPuzzleEngineTests",
            dependencies: ["SudokuPuzzleEngine"]
        ),
    ]
)
