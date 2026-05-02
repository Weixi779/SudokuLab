public struct RulesValidator: Validator {
    public init() {}

    public func validate(_ grid: PuzzleGrid) throws {
        try ValidationFailure.throwIfNeeded(ValidationIssues.duplicateIssues(in: grid))
    }
}
