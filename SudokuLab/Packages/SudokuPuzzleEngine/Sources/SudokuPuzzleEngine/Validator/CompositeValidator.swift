public struct CompositeValidator: Validator {
    private let validators: [any Validator]

    public init(_ validators: any Validator...) {
        self.validators = validators
    }

    public init(_ validators: [any Validator]) {
        self.validators = validators
    }

    public func validate(_ grid: PuzzleGrid) throws {
        var issues: [ValidationIssue] = []

        for validator in validators {
            do {
                try validator.validate(grid)
            } catch let failure as ValidationFailure {
                issues.append(contentsOf: failure.issues)
            } catch {
                throw error
            }
        }

        try ValidationFailure.throwIfNeeded(issues)
    }
}
