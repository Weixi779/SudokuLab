public struct SudokuSquare: Equatable, Hashable, Comparable, Sendable {
    public static let all: [SudokuSquare] = (0..<SudokuLayout.cellCount).map { rawValue in
        SudokuSquare(uncheckedRawValue: rawValue)
    }

    public let rawValue: Int

    public var rowIndex: Int {
        SudokuLayout.rowIndex(forSquareIndex: rawValue)
    }

    public var columnIndex: Int {
        SudokuLayout.columnIndex(forSquareIndex: rawValue)
    }

    public var blockIndex: Int {
        SudokuLayout.blockIndex(rowIndex: rowIndex, columnIndex: columnIndex)
    }

    public init(_ rawValue: Int) throws {
        guard (0..<SudokuLayout.cellCount).contains(rawValue) else {
            throw SudokuError.invalidSquareIndex(rawValue)
        }

        self.rawValue = rawValue
    }

    public init(rowIndex: Int, columnIndex: Int) throws {
        guard (0..<SudokuLayout.size).contains(rowIndex),
            (0..<SudokuLayout.size).contains(columnIndex)
        else {
            throw SudokuError.invalidSquare(rowIndex: rowIndex, columnIndex: columnIndex)
        }

        self.rawValue = SudokuLayout.squareIndex(rowIndex: rowIndex, columnIndex: columnIndex)
    }

    public static func < (lhs: SudokuSquare, rhs: SudokuSquare) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    init(uncheckedRawValue rawValue: Int) {
        self.rawValue = rawValue
    }
}
