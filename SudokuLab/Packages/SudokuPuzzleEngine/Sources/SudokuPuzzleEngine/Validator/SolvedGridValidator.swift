public struct SolvedGridValidator: Validator {
    public init() {}

    public func validate(_ grid: PuzzleGrid) throws {
        var issues = ValidationIssues.duplicateIssues(in: grid)
        let emptyCellIndices = ValidationIssues.emptyCellIndices(in: grid)

        if !emptyCellIndices.isEmpty {
            issues.append(.emptyCells(cellIndices: emptyCellIndices))
        }

        try ValidationFailure.throwIfNeeded(issues)
    }
}
