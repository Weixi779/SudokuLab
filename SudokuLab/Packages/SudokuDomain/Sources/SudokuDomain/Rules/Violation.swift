import SudokuCore

public enum Violation: Equatable, Hashable, Sendable {
    case duplicateDigit(Digit, positions: [Position])
}
