struct RulesValidator: Validator {
    init() {}

    func validate(_ grid: PuzzleGrid) throws {
        try ValidationFailure.throwIfNeeded(ValidationIssues.duplicateIssues(in: grid))
    }
}
