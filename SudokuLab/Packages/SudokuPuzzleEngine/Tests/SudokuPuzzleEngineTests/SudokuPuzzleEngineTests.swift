import SudokuCore
import SudokuDomain
import SudokuPuzzleEngine
import Testing

@Suite
struct SudokuPuzzleEngineTests {
    @Test func solvedBoardSolvesToItself() throws {
        let board = try board(clues: solvedGrid)
        let solution = try #require(try MRVBitmaskBoardSolver().solve(board))

        #expect(solution == board)
    }

    @Test func standardPuzzleSolvesToExpectedBoard() throws {
        let puzzle = try board(clues: standardPuzzle)
        let solution = try #require(try MRVBitmaskBoardSolver().solve(puzzle))

        #expect(solution == (try expectedSolvedBoard(for: standardPuzzle)))
    }

    @Test func solverResultPreservesOriginalCellKindsAndMarksSolvedCellsAsEntries() throws {
        var cells = emptyCells()
        cells[index(row: 0, column: 0)] = .clue(Digit(5))
        cells[index(row: 0, column: 1)] = .entry(Digit(3))
        for index in standardPuzzle.indices
        where standardPuzzle[index] != 0 && cells[index] == .empty {
            cells[index] = .clue(Digit(standardPuzzle[index]))
        }
        let puzzle = try Board(cells: cells)
        let solution = try #require(try MRVBitmaskBoardSolver().solve(puzzle))

        #expect(solution[Position(row: 0, column: 0)] == .clue(Digit(5)))
        #expect(solution[Position(row: 0, column: 1)] == .entry(Digit(3)))
        #expect(solution[Position(row: 0, column: 2)] == .entry(Digit(4)))
    }

    @Test func contradictoryBoardHasNoSolution() throws {
        let board = try board(clues: cells([(0, 0, 5), (0, 1, 5)]))
        let solver = MRVBitmaskBoardSolver()

        #expect(try solver.solve(board) == nil)
        #expect(try solver.solutionCount(for: board, limit: 2) == 0)
        #expect(!(try solver.hasUniqueSolution(board)))
    }

    @Test func standardPuzzleHasUniqueSolution() throws {
        let puzzle = try board(clues: standardPuzzle)

        #expect(try MRVBitmaskBoardSolver().hasUniqueSolution(puzzle))
    }

    @Test func emptyBoardHasMultipleSolutions() throws {
        let solver = MRVBitmaskBoardSolver()
        let board = Board()

        #expect(try solver.solutionCount(for: board, limit: 2) == 2)
        #expect(!(try solver.hasUniqueSolution(board)))
    }

    @Test func solutionCountRespectsLimit() throws {
        let solver = MRVBitmaskBoardSolver()
        let board = Board()

        #expect(try solver.solutionCount(for: board, limit: 0) == 0)
        #expect(try solver.solutionCount(for: board, limit: 1) == 1)
        #expect(try solver.solutionCount(for: board, limit: 2) == 2)
    }

    private func board(clues: [Int]) throws -> Board {
        try Board(clues: clues.map { $0 == 0 ? nil : $0 })
    }

    private func expectedSolvedBoard(for puzzle: [Int]) throws -> Board {
        let cells = zip(puzzle, solvedGrid).map { clue, solvedDigit -> Cell in
            clue == 0 ? .entry(Digit(solvedDigit)) : .clue(Digit(clue))
        }

        return try Board(cells: cells)
    }

    private func cells(_ entries: [(Int, Int, Int)]) -> [Int] {
        var cells = Array(repeating: 0, count: cellCount())

        for (row, column, digit) in entries {
            cells[index(row: row, column: column)] = digit
        }

        return cells
    }

    private func emptyCells() -> [Cell] {
        Array(repeating: .empty, count: cellCount())
    }

    private func index(row: Int, column: Int) -> Int {
        row * BoardSize.standard.sideLength + column
    }

    private func cellCount() -> Int {
        BoardSize.standard.cellCount
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
