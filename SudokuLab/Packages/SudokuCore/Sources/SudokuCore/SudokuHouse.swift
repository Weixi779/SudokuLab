public struct SudokuHouse: Equatable, Hashable, Sendable {
    public enum Kind: Equatable, Hashable, Sendable {
        case row
        case column
        case box
    }

    public static let all: [SudokuHouse] =
        (0..<SudokuGrid.size).map { SudokuHouse(uncheckedKind: .row, index: $0) }
        + (0..<SudokuGrid.size).map { SudokuHouse(uncheckedKind: .column, index: $0) }
        + (0..<SudokuGrid.size).map { SudokuHouse(uncheckedKind: .box, index: $0) }

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
        case .box:
            boxSquares
        }
    }

    public init(kind: Kind, index: Int) throws {
        guard (0..<SudokuGrid.size).contains(index) else {
            throw SudokuError.invalidHouseIndex(kind: kind, index: index)
        }

        self.kind = kind
        self.index = index
    }

    private var boxSquares: [SudokuSquare] {
        let firstRow = (index / SudokuGrid.boxSide) * SudokuGrid.boxSide
        let firstColumn = (index % SudokuGrid.boxSide) * SudokuGrid.boxSide

        return (firstRow..<(firstRow + SudokuGrid.boxSide)).flatMap { rowIndex in
            (firstColumn..<(firstColumn + SudokuGrid.boxSide)).map { columnIndex in
                SudokuSquare(uncheckedRawValue: rowIndex * SudokuGrid.size + columnIndex)
            }
        }
    }

    private init(uncheckedKind kind: Kind, index: Int) {
        self.kind = kind
        self.index = index
    }
}
