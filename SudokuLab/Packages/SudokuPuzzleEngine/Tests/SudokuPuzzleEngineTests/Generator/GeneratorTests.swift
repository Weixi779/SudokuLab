import SudokuCore
import SudokuDomain
import SudokuPuzzleEngine
import Testing

@Suite
struct GeneratorTests {
    @Test func locallyMinimalGenerationProducesUniquePuzzle() throws {
        var generator = RandomizedBoardGenerator(
            randomNumberGenerator: SeededRandomNumberGenerator(seed: 1))

        let generated = try generator.generate()

        #expect(SudokuRules().validate(generated.solution).isEmpty)
        #expect(
            generated.solution.positions.allSatisfy { position in
                generated.solution[position].digit != nil
            })
        #expect(SudokuRules().validate(generated.puzzle).isEmpty)
        #expect(try MRVBitmaskBoardSolver().hasUniqueSolution(generated.puzzle))
        #expect(
            digits(in: try #require(try MRVBitmaskBoardSolver().solve(generated.puzzle)))
                == digits(in: generated.solution)
        )
        #expect(
            generated.clueCount
                == generated.puzzle.positions.filter { position in
                    generated.puzzle[position].isClue
                }.count)
    }

    @Test func locallyMinimalPuzzleCannotRemoveAnyRemainingClue() throws {
        var generator = RandomizedBoardGenerator(
            randomNumberGenerator: SeededRandomNumberGenerator(seed: 2))
        let generated = try generator.generate()
        let solver = MRVBitmaskBoardSolver()

        for (index, position) in generated.puzzle.positions.enumerated()
        where generated.puzzle[position].isClue {
            var cells = generated.puzzle.positions.map { generated.puzzle[$0] }
            cells[index] = .empty
            let candidate = try Board(cells: cells)

            #expect(try solver.solutionCount(for: candidate, limit: 2) == 2)
        }
    }

    @Test func targetClueCountStopsAtTarget() throws {
        var generator = RandomizedBoardGenerator(
            configuration: BoardGenerationConfiguration(goal: .targetClueCount(40)),
            randomNumberGenerator: SeededRandomNumberGenerator(seed: 3))

        let generated = try generator.generate()

        #expect(generated.clueCount == 40)
        #expect(try MRVBitmaskBoardSolver().hasUniqueSolution(generated.puzzle))
        #expect(
            digits(in: try #require(try MRVBitmaskBoardSolver().solve(generated.puzzle)))
                == digits(in: generated.solution)
        )
    }

    @Test func generationIsDeterministicForSeed() throws {
        var firstGenerator = RandomizedBoardGenerator(
            configuration: BoardGenerationConfiguration(goal: .targetClueCount(40)),
            randomNumberGenerator: SeededRandomNumberGenerator(seed: 4))
        var secondGenerator = RandomizedBoardGenerator(
            configuration: BoardGenerationConfiguration(goal: .targetClueCount(40)),
            randomNumberGenerator: SeededRandomNumberGenerator(seed: 4))

        let first = try firstGenerator.generate()
        let second = try secondGenerator.generate()

        #expect(first == second)
    }

    @Test func generatorConfigurationCanBeCopiedAndReplaced() {
        var generator = RandomizedBoardGenerator(
            randomNumberGenerator: SeededRandomNumberGenerator(seed: 7))
        let configuration = BoardGenerationConfiguration(goal: .targetClueCount(40))

        generator.configuration = configuration

        #expect(generator.configuration == configuration)
    }

    @Test func generatorRejectsInvalidTargetClueCount() {
        #expect(throws: BoardGenerationError.invalidTargetClueCount(-1)) {
            var generator = RandomizedBoardGenerator(
                configuration: BoardGenerationConfiguration(goal: .targetClueCount(-1)),
                randomNumberGenerator: SeededRandomNumberGenerator(seed: 5))
            _ = try generator.generate()
        }

        #expect(throws: BoardGenerationError.invalidTargetClueCount(82)) {
            var generator = RandomizedBoardGenerator(
                configuration: BoardGenerationConfiguration(goal: .targetClueCount(82)),
                randomNumberGenerator: SeededRandomNumberGenerator(seed: 5))
            _ = try generator.generate()
        }
    }

    @Test func generatorRejectsUnsupportedBoardSize() {
        let boardSize = BoardSize(size: 4, blockSide: 2)

        #expect(throws: BoardGenerationError.unsupportedBoardSize(boardSize)) {
            var generator = RandomizedBoardGenerator(
                configuration: BoardGenerationConfiguration(boardSize: boardSize),
                randomNumberGenerator: SeededRandomNumberGenerator(seed: 6))
            _ = try generator.generate()
        }
    }

    private func digits(in board: Board) -> [Int] {
        board.positions.map { position in
            board[position].digit?.value ?? 0
        }
    }

    private struct SeededRandomNumberGenerator: RandomNumberGenerator, Sendable {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next() -> UInt64 {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return state
        }
    }
}
