struct CompositeValidator: Validator {
    private let validators: [any Validator]

    init(_ validators: any Validator...) {
        self.validators = validators
    }

    init(_ validators: [any Validator]) {
        self.validators = validators
    }

    func validate(_ grid: PuzzleGrid) throws {
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
