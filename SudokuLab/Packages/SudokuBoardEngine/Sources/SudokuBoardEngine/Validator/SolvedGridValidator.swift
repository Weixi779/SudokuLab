struct SolvedGridValidator: Validator {
    init() {}

    func validate(_ grid: PuzzleGrid) throws {
        var issues = ValidationIssues.duplicateIssues(in: grid)
        let emptyPositions = ValidationIssues.emptyPositions(in: grid)

        if !emptyPositions.isEmpty {
            issues.append(.emptyCells(positions: emptyPositions))
        }

        try ValidationFailure.throwIfNeeded(issues)
    }
}
