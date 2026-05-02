import SudokuPuzzleEngine
import Testing

@Suite
struct SudokuPuzzleEngineTests {
    @Test func emptyGridStoresZeros() {
        let grid = PuzzleGrid()

        #expect(PuzzleGrid.size == 9)
        #expect(PuzzleGrid.cellCount == 81)
        #expect(PuzzleGrid.blockSide == 3)
        #expect(grid.cells.count == PuzzleGrid.cellCount)
        #expect(grid.cells.allSatisfy { $0 == 0 })
        #expect(grid.value(at: 0) == 0)
        #expect(grid[row: 8, column: 8] == 0)
    }

    @Test func gridAcceptsValidDigitsAndExposesSnapshot() throws {
        var cells = Array(repeating: 0, count: PuzzleGrid.cellCount)
        cells[0] = 8
        cells[80] = 9

        let grid = try PuzzleGrid(cells: cells)

        #expect(grid.value(at: 0) == 8)
        #expect(grid.value(row: 8, column: 8) == 9)
        #expect(grid[80] == 9)
        #expect(grid.cells == cells)
    }

    @Test func gridRejectsInvalidCellCount() {
        #expect(throws: PuzzleGridError.invalidCellCount(value: 0, expected: 81)) {
            _ = try PuzzleGrid(cells: [])
        }
    }

    @Test func gridRejectsInvalidDigit() {
        #expect(throws: PuzzleGridError.invalidDigit(-1)) {
            var cells = Array(repeating: 0, count: PuzzleGrid.cellCount)
            cells[0] = -1
            _ = try PuzzleGrid(cells: cells)
        }

        #expect(throws: PuzzleGridError.invalidDigit(10)) {
            var cells = Array(repeating: 0, count: PuzzleGrid.cellCount)
            cells[0] = 10
            _ = try PuzzleGrid(cells: cells)
        }
    }

    @Test func solvedGridSolvesToItself() throws {
        let grid = try PuzzleGrid(cells: solvedGrid)
        let solution = try #require(Solver().solve(grid))

        #expect(solution == grid)
    }

    @Test func standardPuzzleSolvesToExpectedGrid() throws {
        let puzzle = try PuzzleGrid(cells: standardPuzzle)
        let solution = try #require(Solver().solve(puzzle))

        #expect(solution == (try PuzzleGrid(cells: solvedGrid)))
    }

    @Test func contradictoryGridHasNoSolution() throws {
        var cells = Array(repeating: 0, count: PuzzleGrid.cellCount)
        cells[0] = 5
        cells[1] = 5
        let grid = try PuzzleGrid(cells: cells)
        let solver = Solver()

        #expect(solver.solve(grid) == nil)
        #expect(solver.solutionCount(for: grid) == 0)
        #expect(!solver.hasUniqueSolution(grid))
    }

    @Test func standardPuzzleHasUniqueSolution() throws {
        let puzzle = try PuzzleGrid(cells: standardPuzzle)

        #expect(Solver().hasUniqueSolution(puzzle))
    }

    @Test func emptyGridHasMultipleSolutions() {
        let solver = Solver()

        #expect(solver.solutionCount(for: PuzzleGrid(), limit: 2) == 2)
        #expect(!solver.hasUniqueSolution(PuzzleGrid()))
    }

    @Test func solutionCountRespectsLimit() {
        let solver = Solver()
        let grid = PuzzleGrid()

        #expect(solver.solutionCount(for: grid, limit: 0) == 0)
        #expect(solver.solutionCount(for: grid, limit: 1) == 1)
        #expect(solver.solutionCount(for: grid, limit: 2) == 2)
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
