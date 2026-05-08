struct UniqueSolutionValidator: Validator {
    private let solver: MRVBitmaskBoardSolver

    init(solver: MRVBitmaskBoardSolver = MRVBitmaskBoardSolver()) {
        self.solver = solver
    }

    func validate(_ grid: PuzzleGrid) throws {
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
