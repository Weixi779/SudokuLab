import SudokuCore

public enum SudokuRuleViolation: Equatable, Hashable, Sendable {
    case duplicateDigit(Digit, positions: [Position])
}
