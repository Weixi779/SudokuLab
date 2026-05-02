import SudokuCore

public struct SudokuRules: Sendable {
    public init() {}

    public func validate(_ grid: SudokuGrid) -> [SudokuRuleViolation] {
        SudokuDuplicateScanner.duplicates { square in
            grid[square].digit
        }.map { duplicate in
            .duplicateDigit(
                duplicate.digit,
                house: duplicate.house,
                squares: duplicate.squares
            )
        }
    }
}
