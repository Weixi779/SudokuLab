import SudokuPuzzleEngine
import Testing

@Suite
struct GeneratorTests {
    @Test func locallyMinimalGenerationProducesUniquePuzzle() throws {
        var generator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 1))

        let generated = try generator.generate()

        try SolvedGridValidator().validate(generated.solution)
        try RulesValidator().validate(generated.puzzle)
        try UniqueSolutionValidator().validate(generated.puzzle)
        #expect(Solver().solve(generated.puzzle) == generated.solution)
        #expect(generated.clueCount == generated.puzzle.cells.filter { $0 != 0 }.count)
    }

    @Test func locallyMinimalPuzzleCannotRemoveAnyRemainingClue() throws {
        var generator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 2))
        let generated = try generator.generate()
        let solver = Solver()

        for cellIndex in generated.puzzle.cells.indices where generated.puzzle[cellIndex] != 0 {
            var cells = generated.puzzle.cells
            cells[cellIndex] = 0
            let candidate = try PuzzleGrid(cells: cells)

            #expect(solver.solutionCount(for: candidate, limit: 2) == 2)
        }
    }

    @Test func targetClueCountStopsAtTarget() throws {
        var generator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 3))

        let generated = try generator.generate(
            options: GeneratorOptions(goal: .targetClueCount(40))
        )

        #expect(generated.clueCount == 40)
        try UniqueSolutionValidator().validate(generated.puzzle)
        #expect(Solver().solve(generated.puzzle) == generated.solution)
    }

    @Test func generationIsDeterministicForSeed() throws {
        var firstGenerator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 4))
        var secondGenerator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 4))

        let first = try firstGenerator.generate(
            options: GeneratorOptions(goal: .targetClueCount(40)))
        let second = try secondGenerator.generate(
            options: GeneratorOptions(goal: .targetClueCount(40)))

        #expect(first == second)
    }

    @Test func generatorRejectsInvalidTargetClueCount() {
        #expect(throws: GeneratorError.invalidTargetClueCount(-1)) {
            var generator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 5))
            _ = try generator.generate(options: GeneratorOptions(goal: .targetClueCount(-1)))
        }

        #expect(throws: GeneratorError.invalidTargetClueCount(82)) {
            var generator = Generator(randomNumberGenerator: SeededRandomNumberGenerator(seed: 5))
            _ = try generator.generate(options: GeneratorOptions(goal: .targetClueCount(82)))
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
