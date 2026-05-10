import SudokuDomain

public struct RandomizedBoardGenerator<Random: RandomNumberGenerator & Sendable>: BoardGenerator {
    public var configuration: BoardGenerationConfiguration
    private var randomNumberGenerator: Random

    public init(
        configuration: BoardGenerationConfiguration = BoardGenerationConfiguration(),
        randomNumberGenerator: Random
    ) {
        self.configuration = configuration
        self.randomNumberGenerator = randomNumberGenerator
    }

    public mutating func generate() throws -> GeneratedBoard {
        let targetClueCount = try validatedTargetClueCount(for: configuration.goal)
        guard let solution = generateSolution() else {
            throw BoardGenerationError.unableToGenerateSolution
        }

        let puzzle = try removeClues(from: solution, targetClueCount: targetClueCount)
        return GeneratedBoard(
            puzzle: try puzzle.clueBoard(),
            solution: try solution.entryBoard()
        )
    }

    private mutating func generateSolution() -> BoardDigits? {
        var builder = SolutionBuilder()
        guard builder.fill(using: &randomNumberGenerator) else { return nil }

        return BoardDigits(uncheckedDigits: builder.digits)
    }

    private mutating func removeClues(from solution: BoardDigits, targetClueCount: Int?) throws
        -> BoardDigits
    {
        var puzzleDigits = solution.digits
        var clueCount = BoardDigits.cellCount
        var removalOrder = Array(0..<BoardDigits.cellCount)
        let solver = MRVBitmaskBoardSolver()

        removalOrder.shuffle(using: &randomNumberGenerator)

        for cellIndex in removalOrder {
            guard targetClueCount.map({ clueCount > $0 }) ?? true else { break }

            let removedDigit = puzzleDigits[cellIndex]
            guard removedDigit != 0 else { continue }

            puzzleDigits[cellIndex] = 0
            let candidate = BoardDigits(uncheckedDigits: puzzleDigits)

            if solver.solutionCount(for: candidate, limit: 2) == 1 {
                clueCount -= 1
            } else {
                puzzleDigits[cellIndex] = removedDigit
            }
        }

        let puzzle = BoardDigits(uncheckedDigits: puzzleDigits)

        if let targetClueCount, clueCount != targetClueCount {
            throw BoardGenerationError.unableToReachTargetClueCount(
                target: targetClueCount,
                actual: clueCount
            )
        }

        return puzzle
    }

    private func validatedTargetClueCount(for goal: BoardGenerationGoal) throws -> Int? {
        switch goal {
        case .locallyMinimal:
            return nil
        case .targetClueCount(let targetClueCount):
            guard (0...BoardDigits.cellCount).contains(targetClueCount) else {
                throw BoardGenerationError.invalidTargetClueCount(targetClueCount)
            }

            return targetClueCount
        }
    }
}

extension RandomizedBoardGenerator where Random == SystemRandomNumberGenerator {
    public init(configuration: BoardGenerationConfiguration = BoardGenerationConfiguration()) {
        self.init(
            configuration: configuration,
            randomNumberGenerator: SystemRandomNumberGenerator()
        )
    }
}
