// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SudokuDomain",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "SudokuDomain",
            targets: ["SudokuDomain"]
        )
    ],
    dependencies: [
        .package(path: "../SudokuCore")
    ],
    targets: [
        .target(
            name: "SudokuDomain",
            dependencies: [
                .product(name: "SudokuCore", package: "SudokuCore")
            ]
        ),
        .testTarget(
            name: "SudokuDomainTests",
            dependencies: [
                "SudokuDomain",
                .product(name: "SudokuCore", package: "SudokuCore"),
            ]
        ),
    ]
)
