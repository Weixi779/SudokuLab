public struct SudokuHouse: Equatable, Hashable, Sendable {
    public enum Kind: Equatable, Hashable, Sendable {
        case row
        case column
        case block
    }

    public static let all: [SudokuHouse] =
        (0..<SudokuLayout.size).map { SudokuHouse(uncheckedKind: .row, index: $0) }
        + (0..<SudokuLayout.size).map { SudokuHouse(uncheckedKind: .column, index: $0) }
        + (0..<SudokuLayout.size).map { SudokuHouse(uncheckedKind: .block, index: $0) }

    public let kind: Kind
    public let index: Int

    public var squares: [SudokuSquare] {
        switch kind {
        case .row:
            (0..<SudokuLayout.size).map { columnIndex in
                SudokuSquare(
                    uncheckedRawValue: SudokuLayout.squareIndex(
                        rowIndex: index,
                        columnIndex: columnIndex
                    )
                )
            }
        case .column:
            (0..<SudokuLayout.size).map { rowIndex in
                SudokuSquare(
                    uncheckedRawValue: SudokuLayout.squareIndex(
                        rowIndex: rowIndex,
                        columnIndex: index
                    )
                )
            }
        case .block:
            blockSquares
        }
    }

    public init(kind: Kind, index: Int) throws {
        guard (0..<SudokuLayout.size).contains(index) else {
            throw SudokuError.invalidHouseIndex(kind: kind, index: index)
        }

        self.kind = kind
        self.index = index
    }

    public static func row(_ index: Int) throws -> SudokuHouse {
        try SudokuHouse(kind: .row, index: index)
    }

    public static func column(_ index: Int) throws -> SudokuHouse {
        try SudokuHouse(kind: .column, index: index)
    }

    public static func block(_ index: Int) throws -> SudokuHouse {
        try SudokuHouse(kind: .block, index: index)
    }

    private var blockSquares: [SudokuSquare] {
        let firstRow = (index / SudokuLayout.blockSide) * SudokuLayout.blockSide
        let firstColumn = (index % SudokuLayout.blockSide) * SudokuLayout.blockSide

        return (firstRow..<(firstRow + SudokuLayout.blockSide)).flatMap { rowIndex in
            (firstColumn..<(firstColumn + SudokuLayout.blockSide)).map { columnIndex in
                SudokuSquare(
                    uncheckedRawValue: SudokuLayout.squareIndex(
                        rowIndex: rowIndex,
                        columnIndex: columnIndex
                    )
                )
            }
        }
    }

    private init(uncheckedKind kind: Kind, index: Int) {
        self.kind = kind
        self.index = index
    }
}
