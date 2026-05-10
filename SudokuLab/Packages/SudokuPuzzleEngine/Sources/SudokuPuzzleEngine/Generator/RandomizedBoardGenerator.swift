import SudokuCore
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
            puzzle: try Self.clueBoard(from: puzzle),
            solution: try Self.entryBoard(from: solution)
        )
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
        var clueCount = StandardGrid.cellCount
        var removalOrder = Array(0..<StandardGrid.cellCount)
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
            guard (0...StandardGrid.cellCount).contains(targetClueCount) else {
                throw BoardGenerationError.invalidTargetClueCount(targetClueCount)
            }

            return targetClueCount
        }
    }

    private static func clueBoard(from grid: PuzzleGrid) throws -> Board {
        try Board(
            clues: grid.cells.map { digit in
                digit == 0 ? nil : digit
            }
        )
    }

    private static func entryBoard(from grid: PuzzleGrid) throws -> Board {
        try Board(
            cells: grid.cells.map { digit in
                digit == 0 ? .empty : .entry(Digit(digit))
            }
        )
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
