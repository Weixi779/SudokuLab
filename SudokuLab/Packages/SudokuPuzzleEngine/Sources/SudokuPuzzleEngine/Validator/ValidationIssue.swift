import SudokuCore

enum ValidationIssue: Error, Equatable, Hashable, Sendable {
    case duplicateDigit(digit: Digit, positions: [Position])
    case emptyCells(positions: [Position])
    case noSolution
    case multipleSolutions
}
