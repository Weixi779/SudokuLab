public struct ShortCircuitCompositeValidator: Validator {
    private let validators: [any Validator]

    public init(_ validators: any Validator...) {
        self.validators = validators
    }

    public init(_ validators: [any Validator]) {
        self.validators = validators
    }

    public func validate(_ grid: PuzzleGrid) throws {
        for validator in validators {
            try validator.validate(grid)
        }
    }
}
