public enum SudokuError: Error, Equatable, Sendable {
    case invalidDigit(Int)
    case invalidSquareIndex(Int)
    case invalidSquare(rowIndex: Int, columnIndex: Int)
    case invalidHouseIndex(kind: SudokuHouse.Kind, index: Int)
}
