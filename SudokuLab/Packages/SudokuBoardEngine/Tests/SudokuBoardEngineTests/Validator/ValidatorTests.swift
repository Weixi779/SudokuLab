import SudokuCore
import Testing

@testable import SudokuBoardEngine

@Suite
struct ValidatorTests {
    @Test func rulesValidatorAcceptsValidPartialGrid() throws {
        try RulesValidator().validate(try PuzzleGrid(cells: standardPuzzle))
    }

    @Test func rulesValidatorReportsRowDuplicate() throws {
        let grid = try PuzzleGrid(cells: cells([(0, 0, 5), (0, 3, 5)]))
        let expected = ValidationFailure(issues: [
            .duplicateDigit(
                digit: Digit(5),
                positions: [
                    Position(row: 0, column: 0),
                    Position(row: 0, column: 3),
                ]
            )
        ])

        #expect(throws: expected) {
            try RulesValidator().validate(grid)
        }
    }

    @Test func rulesValidatorReportsColumnDuplicate() throws {
        let grid = try PuzzleGrid(cells: cells([(0, 0, 5), (3, 0, 5)]))
        let expected = ValidationFailure(issues: [
            .duplicateDigit(
                digit: Digit(5),
                positions: [
                    Position(row: 0, column: 0),
                    Position(row: 3, column: 0),
                ]
            )
        ])

        #expect(throws: expected) {
            try RulesValidator().validate(grid)
        }
    }

    @Test func rulesValidatorReportsBlockDuplicate() throws {
        let grid = try PuzzleGrid(cells: cells([(0, 0, 5), (1, 1, 5)]))
        let expected = ValidationFailure(issues: [
            .duplicateDigit(
                digit: Digit(5),
                positions: [
                    Position(row: 0, column: 0),
                    Position(row: 1, column: 1),
                ]
            )
        ])

        #expect(throws: expected) {
            try RulesValidator().validate(grid)
        }
    }

    @Test func solvedGridValidatorAcceptsSolvedGrid() throws {
        try SolvedGridValidator().validate(try PuzzleGrid(cells: solvedGrid))
    }

    @Test func solvedGridValidatorReportsEmptyCells() throws {
        let grid = try PuzzleGrid(cells: standardPuzzle)
        let failure = try validationFailure {
            try SolvedGridValidator().validate(grid)
        }

        #expect(failure.issues == [.emptyCells(positions: emptyPositions(in: standardPuzzle))])
    }

    @Test func uniqueSolutionValidatorAcceptsUniquePuzzle() throws {
        try UniqueSolutionValidator().validate(try PuzzleGrid(cells: standardPuzzle))
    }

    @Test func uniqueSolutionValidatorReportsNoSolution() throws {
        let grid = try PuzzleGrid(cells: noCandidatePuzzle)

        #expect(throws: ValidationFailure(issues: [.noSolution])) {
            try UniqueSolutionValidator().validate(grid)
        }
    }

    @Test func uniqueSolutionValidatorReportsMultipleSolutions() {
        #expect(throws: ValidationFailure(issues: [.multipleSolutions])) {
            try UniqueSolutionValidator().validate(PuzzleGrid())
        }
    }

    @Test func compositeValidatorAggregatesValidationFailures() {
        let validator = CompositeValidator(
            StaticValidator(issue: .noSolution),
            StaticValidator(issue: .multipleSolutions)
        )

        #expect(throws: ValidationFailure(issues: [.noSolution, .multipleSolutions])) {
            try validator.validate(PuzzleGrid())
        }
    }

    @Test func shortCircuitCompositeValidatorStopsAtFirstFailure() {
        let validator = ShortCircuitCompositeValidator(
            StaticValidator(issue: .noSolution),
            StaticValidator(issue: .multipleSolutions)
        )

        #expect(throws: ValidationFailure(issues: [.noSolution])) {
            try validator.validate(PuzzleGrid())
        }
    }

    private func validationFailure(_ operation: () throws -> Void) throws -> ValidationFailure {
        do {
            try operation()
        } catch let failure as ValidationFailure {
            return failure
        } catch {
            throw error
        }

        return try #require(nil as ValidationFailure?)
    }

    private func cells(_ entries: [(Int, Int, Int)]) -> [Int] {
        var cells = Array(repeating: 0, count: PuzzleGrid.cellCount)

        for (row, column, digit) in entries {
            cells[row * PuzzleGrid.size + column] = digit
        }

        return cells
    }

    private func emptyPositions(in cells: [Int]) -> [Position] {
        cells.indices.compactMap { index in
            guard cells[index] == 0 else { return nil }
            return Position(
                row: index / PuzzleGrid.size,
                column: index % PuzzleGrid.size
            )
        }
    }

    private struct StaticValidator: Validator {
        let issue: ValidationIssue

        func validate(_ grid: PuzzleGrid) throws {
            try ValidationFailure.throwIfNeeded([issue])
        }
    }

    private var noCandidatePuzzle: [Int] {
        [
            0, 1, 2, 3, 4, 5, 6, 7, 8,
            9, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
        ]
    }

    private var standardPuzzle: [Int] {
        [
            5, 3, 0, 0, 7, 0, 0, 0, 0,
            6, 0, 0, 1, 9, 5, 0, 0, 0,
            0, 9, 8, 0, 0, 0, 0, 6, 0,
            8, 0, 0, 0, 6, 0, 0, 0, 3,
            4, 0, 0, 8, 0, 3, 0, 0, 1,
            7, 0, 0, 0, 2, 0, 0, 0, 6,
            0, 6, 0, 0, 0, 0, 2, 8, 0,
            0, 0, 0, 4, 1, 9, 0, 0, 5,
            0, 0, 0, 0, 8, 0, 0, 7, 9,
        ]
    }

    private var solvedGrid: [Int] {
        [
            5, 3, 4, 6, 7, 8, 9, 1, 2,
            6, 7, 2, 1, 9, 5, 3, 4, 8,
            1, 9, 8, 3, 4, 2, 5, 6, 7,
            8, 5, 9, 7, 6, 1, 4, 2, 3,
            4, 2, 6, 8, 5, 3, 7, 9, 1,
            7, 1, 3, 9, 2, 4, 8, 5, 6,
            9, 6, 1, 5, 3, 7, 2, 8, 4,
            2, 8, 7, 4, 1, 9, 6, 3, 5,
            3, 4, 5, 2, 8, 6, 1, 7, 9,
        ]
    }
}
