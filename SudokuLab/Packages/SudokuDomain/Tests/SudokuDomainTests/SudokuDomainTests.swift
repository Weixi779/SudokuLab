import SudokuCore
import SudokuDomain
import Testing

@Suite
struct SudokuDomainTests {
    @Test func emptyBoardHasExpectedCells() throws {
        let board = Board()

        #expect(Board.size == 9)
        #expect(Board.cellCount == 81)
        #expect(Board.blockSide == 3)
        #expect(board[Position(row: 0, column: 0)] == .empty)
        #expect(board.cell(at: Position(row: 8, column: 8)) == .empty)
    }

    @Test func boardCanBeInitializedFromCells() throws {
        let digit = Digit(5)
        var cells = Array(repeating: Cell.empty, count: Board.cellCount)
        cells[0] = .clue(digit)

        let board = try Board(cells: cells)

        #expect(board[Position(row: 0, column: 0)] == .clue(digit))
    }

    @Test func boardCanBeInitializedFromClues() throws {
        var clues = Array(repeating: Int?.none, count: Board.cellCount)
        clues[0] = 8

        let board = try Board(clues: clues)

        #expect(board[Position(row: 0, column: 0)] == .clue(Digit(8)))
        #expect(board[Position(row: 0, column: 1)] == .empty)
    }

    @Test func boardRejectsInvalidCellCount() {
        #expect(throws: SudokuDomainError.invalidCellCount(value: 0, expected: 81)) {
            try Board(cells: [])
        }
        #expect(throws: SudokuDomainError.invalidCellCount(value: 0, expected: 81)) {
            try Board(clues: [])
        }
    }

    @Test func emptyBoardHasNoViolations() {
        let board = Board()

        #expect(SudokuRules().validate(board).isEmpty)
    }

    @Test func solvedBoardHasNoViolations() throws {
        let board = try Board(clues: solvedBoard)

        #expect(SudokuRules().validate(board).isEmpty)
    }

    @Test func rowDuplicateProducesExactViolation() throws {
        let board = try Board(clues: clues([(0, 0, 5), (0, 3, 5)]))

        #expect(
            SudokuRules().validate(board) == [
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
        let board = try Board(clues: clues([(0, 0, 5), (3, 0, 5)]))

        #expect(
            SudokuRules().validate(board) == [
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
        let board = try Board(clues: clues([(0, 0, 5), (1, 1, 5)]))

        #expect(
            SudokuRules().validate(board) == [
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
        let board = try Board(clues: clues([(0, 0, 5)]))

        #expect(SudokuRules().validate(board).isEmpty)
    }

    @Test func clueAndEntryBothParticipateInViolations() throws {
        var board = try Board(clues: clues([(0, 0, 5)]))
        try board.setEntry(Digit(5), at: Position(row: 0, column: 3))

        #expect(
            SudokuRules().validate(board) == [
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
        var board = Board()
        let position = Position(row: 2, column: 4)

        try board.setEntry(Digit(8), at: position)
        #expect(board[position] == .entry(Digit(8)))

        try board.setEntry(Digit(9), at: position)
        #expect(board[position] == .entry(Digit(9)))

        try board.setEntry(nil, at: position)
        #expect(board[position] == .empty)
    }

    @Test func clueRejectsAnyEntryChange() throws {
        var board = try Board(clues: clues([(0, 0, 5)]))
        let position = Position(row: 0, column: 0)

        #expect(throws: SudokuDomainError.cannotChangeClue(position)) {
            try board.setEntry(Digit(8), at: position)
        }
        #expect(throws: SudokuDomainError.cannotChangeClue(position)) {
            try board.setEntry(nil, at: position)
        }
    }

    private func clues(_ entries: [(Int, Int, Int)]) -> [Int?] {
        var clues = Array(repeating: Int?.none, count: Board.cellCount)

        for (rowIndex, columnIndex, value) in entries {
            clues[rowIndex * Board.size + columnIndex] = value
        }

        return clues
    }

    private var solvedBoard: [Int?] {
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
