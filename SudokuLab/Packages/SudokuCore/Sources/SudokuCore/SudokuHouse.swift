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

    public var positions: [Position] {
        switch kind {
        case .row:
            (0..<SudokuLayout.size).map { column in
                Position(row: index, column: column)
            }
        case .column:
            (0..<SudokuLayout.size).map { row in
                Position(row: row, column: index)
            }
        case .block:
            blockPositions
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

    private var blockPositions: [Position] {
        let firstRow = (index / SudokuLayout.blockSide) * SudokuLayout.blockSide
        let firstColumn = (index % SudokuLayout.blockSide) * SudokuLayout.blockSide

        return (firstRow..<(firstRow + SudokuLayout.blockSide)).flatMap { row in
            (firstColumn..<(firstColumn + SudokuLayout.blockSide)).map { column in
                Position(row: row, column: column)
            }
        }
    }

    private init(uncheckedKind kind: Kind, index: Int) {
        self.kind = kind
        self.index = index
    }
}
