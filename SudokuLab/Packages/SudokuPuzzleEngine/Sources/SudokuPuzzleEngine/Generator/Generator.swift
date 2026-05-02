public struct Generator<Random: RandomNumberGenerator & Sendable>: Sendable {
    private var randomNumberGenerator: Random

    public init(randomNumberGenerator: Random) {
        self.randomNumberGenerator = randomNumberGenerator
    }

    public mutating func generate(options: GeneratorOptions = GeneratorOptions()) throws
        -> GeneratedPuzzle
    {
        let targetClueCount = try validatedTargetClueCount(for: options.goal)
        guard let solution = generateSolution() else {
            throw GeneratorError.unableToGenerateSolution
        }

        let puzzle = try removeClues(from: solution, targetClueCount: targetClueCount)
        return GeneratedPuzzle(puzzle: puzzle, solution: solution)
    }

    private mutating func generateSolution() -> PuzzleGrid? {
        var builder = SolutionBuilder()
        guard builder.fill(using: &randomNumberGenerator) else { return nil }

        return PuzzleGrid(uncheckedCells: builder.cells)
    }

    private mutating func removeClues(from solution: PuzzleGrid, targetClueCount: Int?) throws
        -> PuzzleGrid
    {
        var puzzleCells = solution.cells
        var clueCount = PuzzleGrid.cellCount
        var removalOrder = Array(0..<PuzzleGrid.cellCount)
        let validator = ShortCircuitCompositeValidator(RulesValidator(), UniqueSolutionValidator())

        removalOrder.shuffle(using: &randomNumberGenerator)

        for cellIndex in removalOrder {
            guard targetClueCount.map({ clueCount > $0 }) ?? true else { break }

            let removedDigit = puzzleCells[cellIndex]
            guard removedDigit != 0 else { continue }

            puzzleCells[cellIndex] = 0
            let candidate = PuzzleGrid(uncheckedCells: puzzleCells)

            do {
                try validator.validate(candidate)
                clueCount -= 1
            } catch {
                puzzleCells[cellIndex] = removedDigit
            }
        }

        let puzzle = PuzzleGrid(uncheckedCells: puzzleCells)

        if let targetClueCount, clueCount != targetClueCount {
            throw GeneratorError.unableToReachTargetClueCount(
                target: targetClueCount,
                actual: clueCount
            )
        }

        return puzzle
    }

    private func validatedTargetClueCount(for goal: GeneratorGoal) throws -> Int? {
        switch goal {
        case .locallyMinimal:
            return nil
        case .targetClueCount(let targetClueCount):
            guard (0...PuzzleGrid.cellCount).contains(targetClueCount) else {
                throw GeneratorError.invalidTargetClueCount(targetClueCount)
            }

            return targetClueCount
        }
    }
}

extension Generator where Random == SystemRandomNumberGenerator {
    public init() {
        self.init(randomNumberGenerator: SystemRandomNumberGenerator())
    }
}
