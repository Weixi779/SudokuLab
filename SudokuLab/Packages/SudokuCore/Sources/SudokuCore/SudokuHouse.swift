public struct SudokuHouse: Equatable, Hashable, Sendable {
    public enum Kind: Equatable, Hashable, Sendable {
        case row
        case column
        case block
    }

    public static let all: [SudokuHouse] =
        (0..<SudokuGrid.size).map { SudokuHouse(uncheckedKind: .row, index: $0) }
        + (0..<SudokuGrid.size).map { SudokuHouse(uncheckedKind: .column, index: $0) }
        + (0..<SudokuGrid.size).map { SudokuHouse(uncheckedKind: .block, index: $0) }

    public let kind: Kind
    public let index: Int

    public var squares: [SudokuSquare] {
        switch kind {
        case .row:
            (0..<SudokuGrid.size).map { columnIndex in
                SudokuSquare(uncheckedRawValue: index * SudokuGrid.size + columnIndex)
            }
        case .column:
            (0..<SudokuGrid.size).map { rowIndex in
                SudokuSquare(uncheckedRawValue: rowIndex * SudokuGrid.size + index)
            }
        case .block:
            blockSquares
        }
    }

    public init(kind: Kind, index: Int) throws {
        guard (0..<SudokuGrid.size).contains(index) else {
            throw SudokuError.invalidHouseIndex(kind: kind, index: index)
        }

        self.kind = kind
        self.index = index
    }

    private var blockSquares: [SudokuSquare] {
        let firstRow = (index / SudokuGrid.blockSide) * SudokuGrid.blockSide
        let firstColumn = (index % SudokuGrid.blockSide) * SudokuGrid.blockSide

        return (firstRow..<(firstRow + SudokuGrid.blockSide)).flatMap { rowIndex in
            (firstColumn..<(firstColumn + SudokuGrid.blockSide)).map { columnIndex in
                SudokuSquare(uncheckedRawValue: rowIndex * SudokuGrid.size + columnIndex)
            }
        }
    }

    private init(uncheckedKind kind: Kind, index: Int) {
        self.kind = kind
        self.index = index
    }
}
