import SudokuCore

public enum BoardError: Error, Equatable, Sendable {
    case invalidCellCount(value: Int, expected: Int)
    case invalidDigit(value: Int, maximum: Int)
    case invalidPosition(Position)
    case cannotChangeClue(Position)
}
