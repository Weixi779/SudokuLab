import SudokuCore

public enum SudokuDomainError: Error, Equatable, Sendable {
    case invalidCellCount(value: Int, expected: Int)
    case cannotChangeClue(SudokuSquare)
}
