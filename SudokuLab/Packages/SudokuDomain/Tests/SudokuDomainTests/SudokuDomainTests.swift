import SudokuCore
import SudokuDomain
import Testing

@Suite
struct SudokuDomainTests {
    @Test func emptyGridHasExpectedCells() throws {
        let grid = SudokuGrid()

        #expect(SudokuGrid.size == 9)
        #expect(SudokuGrid.cellCount == 81)
        #expect(SudokuGrid.blockSide == 3)
        #expect(grid[Position(row: 0, column: 0)] == .empty)
        #expect(grid.cell(at: Position(row: 8, column: 8)) == .empty)
    }

    @Test func gridCanBeInitializedFromCells() throws {
        let digit = Digit(5)
        var cells = Array(repeating: SudokuCell.empty, count: SudokuGrid.cellCount)
        cells[0] = .clue(digit)

        let grid = try SudokuGrid(cells: cells)

        #expect(grid[Position(row: 0, column: 0)] == .clue(digit))
    }

    @Test func gridCanBeInitializedFromClues() throws {
        var clues = Array(repeating: Int?.none, count: SudokuGrid.cellCount)
        clues[0] = 8

        let grid = try SudokuGrid(clues: clues)

        #expect(grid[Position(row: 0, column: 0)] == .clue(Digit(8)))
        #expect(grid[Position(row: 0, column: 1)] == .empty)
    }

    @Test func gridRejectsInvalidCellCount() {
        #expect(throws: SudokuDomainError.invalidCellCount(value: 0, expected: 81)) {
            try SudokuGrid(cells: [])
        }
        #expect(throws: SudokuDomainError.invalidCellCount(value: 0, expected: 81)) {
            try SudokuGrid(clues: [])
        }
    }

    @Test func emptyGridHasNoViolations() {
        let grid = SudokuGrid()

        #expect(SudokuRules().validate(grid).isEmpty)
    }

    @Test func solvedGridHasNoViolations() throws {
        let grid = try SudokuGrid(clues: solvedGrid)

        #expect(SudokuRules().validate(grid).isEmpty)
    }

    @Test func rowDuplicateProducesExactViolation() throws {
        let grid = try SudokuGrid(clues: clues([(0, 0, 5), (0, 3, 5)]))

        #expect(
            SudokuRules().validate(grid) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 0, column: 3),
                    ]
                )
            ]
        )
    }

    @Test func columnDuplicateProducesExactViolation() throws {
        let grid = try SudokuGrid(clues: clues([(0, 0, 5), (3, 0, 5)]))

        #expect(
            SudokuRules().validate(grid) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 3, column: 0),
                    ]
                )
            ]
        )
    }

    @Test func blockDuplicateProducesExactViolation() throws {
        let grid = try SudokuGrid(clues: clues([(0, 0, 5), (1, 1, 5)]))

        #expect(
            SudokuRules().validate(grid) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 1, column: 1),
                    ]
                )
            ]
        )
    }

    @Test func emptyCellsDoNotConflict() throws {
        let grid = try SudokuGrid(clues: clues([(0, 0, 5)]))

        #expect(SudokuRules().validate(grid).isEmpty)
    }

    @Test func clueAndEntryBothParticipateInViolations() throws {
        var grid = try SudokuGrid(clues: clues([(0, 0, 5)]))
        try grid.setEntry(Digit(5), at: Position(row: 0, column: 3))

        #expect(
            SudokuRules().validate(grid) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 0, column: 3),
                    ]
                )
            ]
        )
    }

    @Test func entryCanBeSetReplacedAndCleared() throws {
        var grid = SudokuGrid()
        let position = Position(row: 2, column: 4)

        try grid.setEntry(Digit(8), at: position)
        #expect(grid[position] == .entry(Digit(8)))

        try grid.setEntry(Digit(9), at: position)
        #expect(grid[position] == .entry(Digit(9)))

        try grid.setEntry(nil, at: position)
        #expect(grid[position] == .empty)
    }

    @Test func clueRejectsAnyEntryChange() throws {
        var grid = try SudokuGrid(clues: clues([(0, 0, 5)]))
        let position = Position(row: 0, column: 0)

        #expect(throws: SudokuDomainError.cannotChangeClue(position)) {
            try grid.setEntry(Digit(8), at: position)
        }
        #expect(throws: SudokuDomainError.cannotChangeClue(position)) {
            try grid.setEntry(nil, at: position)
        }
    }

    private func clues(_ entries: [(Int, Int, Int)]) -> [Int?] {
        var clues = Array(repeating: Int?.none, count: SudokuGrid.cellCount)

        for (rowIndex, columnIndex, value) in entries {
            clues[rowIndex * SudokuGrid.size + columnIndex] = value
        }

        return clues
    }

    private var solvedGrid: [Int?] {
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
