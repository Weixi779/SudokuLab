public struct UniqueSolutionValidator: Validator {
    private let solver: Solver

    public init(solver: Solver = Solver()) {
        self.solver = solver
    }

    public func validate(_ grid: PuzzleGrid) throws {
        let solutionCount = solver.solutionCount(for: grid, limit: 2)

        switch solutionCount {
        case 1:
            return
        case 0:
            throw ValidationFailure(issues: [.noSolution])
        default:
            throw ValidationFailure(issues: [.multipleSolutions])
        }
    }
}
