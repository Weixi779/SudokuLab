struct ShortCircuitCompositeValidator: Validator {
    private let validators: [any Validator]

    init(_ validators: any Validator...) {
        self.validators = validators
    }

    init(_ validators: [any Validator]) {
        self.validators = validators
    }

    func validate(_ grid: PuzzleGrid) throws {
        for validator in validators {
            try validator.validate(grid)
        }
    }
}
