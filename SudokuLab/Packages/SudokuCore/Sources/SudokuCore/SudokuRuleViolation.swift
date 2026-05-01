public enum SudokuRuleViolation: Equatable, Hashable, Sendable {
    case duplicateDigit(SudokuDigit, house: SudokuHouse, squares: [SudokuSquare])
}
