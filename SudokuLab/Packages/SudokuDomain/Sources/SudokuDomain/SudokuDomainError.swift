import SudokuCore

public enum SudokuDomainError: Error, Equatable, Sendable {
    case invalidBoardSize(size: Int, blockSide: Int)
    case invalidCellCount(value: Int, expected: Int)
    case invalidDigit(value: Int, maximum: Int)
    case invalidPosition(Position)
    case cannotChangeClue(Position)
}
