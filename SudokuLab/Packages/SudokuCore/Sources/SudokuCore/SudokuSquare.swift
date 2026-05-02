public struct SudokuSquare: Equatable, Hashable, Comparable, Sendable {
    public static let all: [SudokuSquare] = (0..<SudokuGrid.cellCount).map { rawValue in
        SudokuSquare(uncheckedRawValue: rawValue)
    }

    public let rawValue: Int

    public var rowIndex: Int {
        rawValue / SudokuGrid.size
    }

    public var columnIndex: Int {
        rawValue % SudokuGrid.size
    }

    public var blockIndex: Int {
        (rowIndex / SudokuGrid.blockSide) * SudokuGrid.blockSide
            + columnIndex / SudokuGrid.blockSide
    }

    public init(_ rawValue: Int) throws {
        guard (0..<SudokuGrid.cellCount).contains(rawValue) else {
            throw SudokuError.invalidSquareIndex(rawValue)
        }

        self.rawValue = rawValue
    }

    public init(rowIndex: Int, columnIndex: Int) throws {
        guard (0..<SudokuGrid.size).contains(rowIndex),
            (0..<SudokuGrid.size).contains(columnIndex)
        else {
            throw SudokuError.invalidSquare(rowIndex: rowIndex, columnIndex: columnIndex)
        }

        self.rawValue = rowIndex * SudokuGrid.size + columnIndex
    }

    public static func < (lhs: SudokuSquare, rhs: SudokuSquare) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    init(uncheckedRawValue rawValue: Int) {
        self.rawValue = rawValue
    }
}
