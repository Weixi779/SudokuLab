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
    dependencies: [
        .package(path: "../SudokuCore"),
        .package(path: "../SudokuDomain"),
    ],
    targets: [
        .target(
            name: "SudokuPuzzleEngine",
            dependencies: [
                .product(name: "SudokuCore", package: "SudokuCore"),
                .product(name: "SudokuDomain", package: "SudokuDomain"),
            ]
        ),
        .testTarget(
            name: "SudokuPuzzleEngineTests",
            dependencies: [
                "SudokuPuzzleEngine",
                .product(name: "SudokuCore", package: "SudokuCore"),
                .product(name: "SudokuDomain", package: "SudokuDomain"),
            ]
        ),
    ]
)
