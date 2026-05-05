import SudokuCore

public enum ValidationIssue: Error, Equatable, Hashable, Sendable {
    case duplicateDigit(digit: Digit, house: SudokuHouse, positions: [Position])
    case emptyCells(positions: [Position])
    case noSolution
    case multipleSolutions
}
