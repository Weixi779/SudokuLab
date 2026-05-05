import SudokuCore

public enum ValidationIssue: Error, Equatable, Hashable, Sendable {
    case duplicateDigit(digit: Digit, house: SudokuHouse, squares: [SudokuSquare])
    case emptyCells(squares: [SudokuSquare])
    case noSolution
    case multipleSolutions
}
