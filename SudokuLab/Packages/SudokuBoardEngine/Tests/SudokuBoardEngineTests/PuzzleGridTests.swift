import Testing

@testable import SudokuBoardEngine

@Suite
struct PuzzleGridTests {
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
}
