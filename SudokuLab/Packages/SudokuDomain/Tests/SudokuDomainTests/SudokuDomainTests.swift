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
        #expect(grid[try SudokuSquare(0)] == .empty)
        #expect(grid.cell(at: try SudokuSquare(80)) == .empty)
    }

    @Test func gridCanBeInitializedFromCells() throws {
        let digit = try SudokuDigit(5)
        var cells = Array(repeating: SudokuCell.empty, count: SudokuGrid.cellCount)
        cells[0] = .clue(digit)

        let grid = try SudokuGrid(cells: cells)

        #expect(grid[try SudokuSquare(0)] == .clue(digit))
    }

    @Test func gridCanBeInitializedFromClues() throws {
        var clues = Array(repeating: Int?.none, count: SudokuGrid.cellCount)
        clues[0] = 8

        let grid = try SudokuGrid(clues: clues)

        #expect(grid[try SudokuSquare(0)] == .clue(try SudokuDigit(8)))
        #expect(grid[try SudokuSquare(1)] == .empty)
    }

    @Test func gridRejectsInvalidCellCount() {
        #expect(throws: SudokuDomainError.invalidCellCount(value: 0, expected: 81)) {
            try SudokuGrid(cells: [])
        }
        #expect(throws: SudokuDomainError.invalidCellCount(value: 0, expected: 81)) {
            try SudokuGrid(clues: [])
        }
    }

    @Test func gridRejectsInvalidClueValue() {
        var clues = Array(repeating: Int?.none, count: SudokuGrid.cellCount)
        clues[0] = 10

        #expect(throws: SudokuError.invalidDigit(10)) {
            try SudokuGrid(clues: clues)
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
                    try SudokuDigit(5),
                    house: try SudokuHouse(kind: .row, index: 0),
                    squares: [
                        try SudokuSquare(rowIndex: 0, columnIndex: 0),
                        try SudokuSquare(rowIndex: 0, columnIndex: 3),
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
                    try SudokuDigit(5),
                    house: try SudokuHouse(kind: .column, index: 0),
                    squares: [
                        try SudokuSquare(rowIndex: 0, columnIndex: 0),
                        try SudokuSquare(rowIndex: 3, columnIndex: 0),
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
                    try SudokuDigit(5),
                    house: try SudokuHouse(kind: .block, index: 0),
                    squares: [
                        try SudokuSquare(rowIndex: 0, columnIndex: 0),
                        try SudokuSquare(rowIndex: 1, columnIndex: 1),
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
        try grid.setEntry(try SudokuDigit(5), at: try SudokuSquare(rowIndex: 0, columnIndex: 3))

        #expect(
            SudokuRules().validate(grid) == [
                .duplicateDigit(
                    try SudokuDigit(5),
                    house: try SudokuHouse(kind: .row, index: 0),
                    squares: [
                        try SudokuSquare(rowIndex: 0, columnIndex: 0),
                        try SudokuSquare(rowIndex: 0, columnIndex: 3),
                    ]
                )
            ]
        )
    }

    @Test func entryCanBeSetReplacedAndCleared() throws {
        var grid = SudokuGrid()
        let square = try SudokuSquare(rowIndex: 2, columnIndex: 4)

        try grid.setEntry(try SudokuDigit(8), at: square)
        #expect(grid[square] == .entry(try SudokuDigit(8)))

        try grid.setEntry(try SudokuDigit(9), at: square)
        #expect(grid[square] == .entry(try SudokuDigit(9)))

        try grid.setEntry(nil, at: square)
        #expect(grid[square] == .empty)
    }

    @Test func clueRejectsAnyEntryChange() throws {
        var grid = try SudokuGrid(clues: clues([(0, 0, 5)]))
        let square = try SudokuSquare(rowIndex: 0, columnIndex: 0)

        #expect(throws: SudokuDomainError.cannotChangeClue(square)) {
            try grid.setEntry(try SudokuDigit(8), at: square)
        }
        #expect(throws: SudokuDomainError.cannotChangeClue(square)) {
            try grid.setEntry(nil, at: square)
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
