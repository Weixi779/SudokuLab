public struct SolvedGridValidator: Validator {
    public init() {}

    public func validate(_ grid: PuzzleGrid) throws {
        var issues = ValidationIssues.duplicateIssues(in: grid)
        let emptySquares = ValidationIssues.emptySquares(in: grid)

        if !emptySquares.isEmpty {
            issues.append(.emptyCells(squares: emptySquares))
        }

        try ValidationFailure.throwIfNeeded(issues)
    }
}
