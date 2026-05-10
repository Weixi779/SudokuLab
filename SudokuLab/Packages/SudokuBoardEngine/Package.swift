// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SudokuBoardEngine",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "SudokuBoardEngine",
            targets: ["SudokuBoardEngine"]
        )
    ],
    dependencies: [
        .package(path: "../SudokuCore"),
        .package(path: "../SudokuDomain"),
    ],
    targets: [
        .target(
            name: "SudokuBoardEngine",
            dependencies: [
                .product(name: "SudokuCore", package: "SudokuCore"),
                .product(name: "SudokuDomain", package: "SudokuDomain"),
            ]
        ),
        .testTarget(
            name: "SudokuBoardEngineTests",
            dependencies: [
                "SudokuBoardEngine",
                .product(name: "SudokuCore", package: "SudokuCore"),
                .product(name: "SudokuDomain", package: "SudokuDomain"),
            ]
        ),
    ]
)
