import SudokuCore
import SudokuDomain
import Testing

@Suite
struct SudokuDomainTests {
    @Test func emptyBoardHasExpectedCells() throws {
        let board = Board()
        let boardSize = BoardSize.standard

        #expect(board.size == boardSize)
        #expect(board.cellCount == 81)
        #expect(boardSize.size == 9)
        #expect(boardSize.blockSide == 3)
        #expect(board[Position(row: 0, column: 0)] == .empty)
        #expect(try board.cell(at: Position(row: 8, column: 8)) == .empty)
    }

    @Test func boardPositionsUseRowMajorOrder() throws {
        let board = Board()

        #expect(
            board.positions.prefix(5) == [
                Position(row: 0, column: 0),
                Position(row: 0, column: 1),
                Position(row: 0, column: 2),
                Position(row: 0, column: 3),
                Position(row: 0, column: 4),
            ])
        #expect(board.positions.last == Position(row: 8, column: 8))
    }

    @Test func boardExposesRowColumnAndBlockPositions() throws {
        let board = Board()

        #expect(
            board.rows[0] == [
                Position(row: 0, column: 0),
                Position(row: 0, column: 1),
                Position(row: 0, column: 2),
                Position(row: 0, column: 3),
                Position(row: 0, column: 4),
                Position(row: 0, column: 5),
                Position(row: 0, column: 6),
                Position(row: 0, column: 7),
                Position(row: 0, column: 8),
            ])
        #expect(
            board.columns[0] == [
                Position(row: 0, column: 0),
                Position(row: 1, column: 0),
                Position(row: 2, column: 0),
                Position(row: 3, column: 0),
                Position(row: 4, column: 0),
                Position(row: 5, column: 0),
                Position(row: 6, column: 0),
                Position(row: 7, column: 0),
                Position(row: 8, column: 0),
            ])
        #expect(
            board.blocks[0] == [
                Position(row: 0, column: 0),
                Position(row: 0, column: 1),
                Position(row: 0, column: 2),
                Position(row: 1, column: 0),
                Position(row: 1, column: 1),
                Position(row: 1, column: 2),
                Position(row: 2, column: 0),
                Position(row: 2, column: 1),
                Position(row: 2, column: 2),
            ])
        #expect(board[row: 0] == board.rows[0])
        #expect(board[column: 0] == board.columns[0])
        #expect(board[block: 0] == board.blocks[0])
    }

    @Test func boardContainsStandardPositionsAndDigits() throws {
        let board = Board()

        #expect(board.contains(Position(row: 0, column: 0)))
        #expect(board.contains(Position(row: 8, column: 8)))
        #expect(!board.contains(Position(row: 9, column: 0)))
        #expect(!board.contains(Position(row: 0, column: 9)))

        #expect(board.contains(Digit(1)))
        #expect(board.contains(Digit(9)))
        #expect(!board.contains(Digit(0)))
        #expect(!board.contains(Digit(10)))
    }

    @Test func boardSolverDefaultUniqueSolutionCheckUsesSolutionCount() throws {
        let board = Board()

        #expect(try StaticBoardSolver(solutionCount: 1).hasUniqueSolution(board))
        #expect(!(try StaticBoardSolver(solutionCount: 0).hasUniqueSolution(board)))
        #expect(!(try StaticBoardSolver(solutionCount: 2).hasUniqueSolution(board)))
    }

    @Test func boardGenerationCountsCluesInPuzzleOnly() throws {
        var cells = emptyCells()
        cells[index(for: Position(row: 0, column: 0))] = .clue(Digit(1))
        cells[index(for: Position(row: 0, column: 1))] = .entry(Digit(2))
        cells[index(for: Position(row: 0, column: 2))] = .clue(Digit(3))
        let puzzle = try Board(cells: cells)
        let solution = try Board(clues: solvedBoard)
        let generation = GeneratedBoard(puzzle: puzzle, solution: solution)

        #expect(generation.clueCount == 2)
    }

    @Test func boardGenerationConfigurationDefaultsToLocallyMinimal() {
        let configuration = BoardGenerationConfiguration()

        #expect(configuration.goal == .locallyMinimal)
    }

    @Test func uniqueRuleUsesBoardTopology() throws {
        var clues = emptyClues()
        clues[index(for: Position(row: 3, column: 3))] = 4
        clues[index(for: Position(row: 5, column: 5))] = 4
        let board = try Board(clues: clues)

        #expect(
            UniqueRule(board: board).validate(board) == [
                .duplicateDigit(
                    Digit(4),
                    positions: [
                        Position(row: 3, column: 3),
                        Position(row: 5, column: 5),
                    ]
                )
            ]
        )
    }

    @Test func collectionRulesUseBoardRowsColumnsAndBlocks() throws {
        let board = Board()
        let uniqueRule = UniqueRule(board: board)

        #expect(uniqueRule.rowsRule.rules.count == board.size.size)
        #expect(uniqueRule.columnsRule.rules.count == board.size.size)
        #expect(uniqueRule.blocksRule.rules.count == board.size.size)
    }

    @Test func rowColumnAndBlockRulesValidateTheirBoardGroups() throws {
        let rowBoard = try Board(clues: clues([(0, 0, 5), (0, 3, 5)]))
        let columnBoard = try Board(clues: clues([(0, 0, 5), (3, 0, 5)]))
        let blockBoard = try Board(clues: clues([(0, 0, 5), (1, 1, 5)]))
        let rowRule = RowRule(row: 0, on: rowBoard)
        let columnRule = ColumnRule(column: 0, on: columnBoard)
        let blockRule = BlockRule(block: 0, on: blockBoard)

        #expect(rowRule.row == 0)
        #expect(rowRule.positions == rowBoard[row: 0])
        #expect(columnRule.column == 0)
        #expect(columnRule.positions == columnBoard[column: 0])
        #expect(blockRule.block == 0)
        #expect(blockRule.positions == blockBoard[block: 0])

        #expect(
            rowRule.validate(rowBoard) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 0, column: 3),
                    ]
                )
            ]
        )
        #expect(
            columnRule.validate(columnBoard) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 3, column: 0),
                    ]
                )
            ]
        )
        #expect(
            blockRule.validate(blockBoard) == [
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

    @Test func boardCanBeInitializedFromCells() throws {
        let digit = Digit(5)
        let position = Position(row: 0, column: 0)
        var cells = emptyCells()
        cells[index(for: position)] = .clue(digit)

        let board = try Board(cells: cells)

        #expect(board[position] == .clue(digit))
    }

    @Test func boardCanBeInitializedFromClues() throws {
        var clues = emptyClues()
        clues[index(for: Position(row: 0, column: 0))] = 8

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

    @Test func boardRejectsDigitsOutsideStandardRange() throws {
        var cells = emptyCells()
        cells[index(for: Position(row: 0, column: 0))] = .entry(Digit(10))

        #expect(throws: SudokuDomainError.invalidDigit(value: 10, maximum: 9)) {
            try Board(cells: cells)
        }

        var clues = emptyClues()
        clues[index(for: Position(row: 0, column: 0))] = 10

        #expect(throws: SudokuDomainError.invalidDigit(value: 10, maximum: 9)) {
            try Board(clues: clues)
        }

        var board = Board()

        #expect(throws: SudokuDomainError.invalidDigit(value: 10, maximum: 9)) {
            try board.setEntry(Digit(10), at: Position(row: 0, column: 0))
        }
    }

    @Test func boardRejectsPositionsOutsideStandardGrid() throws {
        let position = Position(row: 9, column: 0)
        var board = Board()

        #expect(throws: SudokuDomainError.invalidPosition(position)) {
            try board.cell(at: position)
        }

        #expect(throws: SudokuDomainError.invalidPosition(position)) {
            try board.setEntry(Digit(1), at: position)
        }
    }

    @Test func emptyBoardHasNoViolations() {
        let board = Board()

        #expect(UniqueRule(board: board).validate(board).isEmpty)
    }

    @Test func solvedBoardHasNoViolations() throws {
        let board = try Board(clues: solvedBoard)

        #expect(UniqueRule(board: board).validate(board).isEmpty)
    }

    @Test func rowDuplicateProducesExactViolation() throws {
        let board = try Board(clues: clues([(0, 0, 5), (0, 3, 5)]))

        #expect(
            UniqueRule(board: board).validate(board) == [
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
            UniqueRule(board: board).validate(board) == [
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
            UniqueRule(board: board).validate(board) == [
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

    @Test func duplicateViolationsAreDeduplicatedAcrossRules() throws {
        let board = try Board(clues: clues([(0, 0, 5), (0, 1, 5)]))

        #expect(
            UniqueRule(board: board).validate(board) == [
                .duplicateDigit(
                    Digit(5),
                    positions: [
                        Position(row: 0, column: 0),
                        Position(row: 0, column: 1),
                    ]
                )
            ]
        )
    }

    @Test func emptyCellsDoNotConflict() throws {
        let board = try Board(clues: clues([(0, 0, 5)]))

        #expect(UniqueRule(board: board).validate(board).isEmpty)
    }

    @Test func clueAndEntryBothParticipateInViolations() throws {
        var board = try Board(clues: clues([(0, 0, 5)]))
        try board.setEntry(Digit(5), at: Position(row: 0, column: 3))

        #expect(
            UniqueRule(board: board).validate(board) == [
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

    @Test func uniqueRuleCandidatesUseBoardDigitsOnEmptyBoard() {
        let board = Board()

        #expect(
            UniqueRule(board: board).candidates(
                at: Position(row: 0, column: 0),
                on: board
            ) == digits(1...9)
        )
    }

    @Test func uniqueRuleCandidatesExcludeRowColumnAndBlockDigits() throws {
        let board = try Board(clues: clues([(0, 1, 1), (1, 0, 2), (1, 1, 3)]))

        #expect(
            UniqueRule(board: board).candidates(
                at: Position(row: 0, column: 0),
                on: board
            ) == digits(4...9)
        )
    }

    @Test func uniqueRuleCandidatesAreEmptyForFilledOrOutOfBoundsPositions() throws {
        let board = try Board(clues: clues([(0, 0, 1)]))
        let rule = UniqueRule(board: board)

        #expect(rule.candidates(at: Position(row: 0, column: 0), on: board) == [])
        #expect(rule.candidates(at: Position(row: 9, column: 0), on: board) == [])
    }

    @Test func rowRuleCandidatesExcludeUsedDigits() throws {
        let board = try Board(clues: clues([(0, 0, 1), (0, 1, 2)]))
        let rule = RowRule(row: 0, on: board)

        #expect(rule.candidates(at: Position(row: 0, column: 2), on: board) == digits(3...9))
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
        var clues = emptyClues()

        for (rowIndex, columnIndex, value) in entries {
            clues[index(for: Position(row: rowIndex, column: columnIndex))] = value
        }

        return clues
    }

    private func emptyCells() -> [Cell] {
        Array(repeating: .empty, count: cellCount())
    }

    private func emptyClues() -> [Int?] {
        Array(repeating: Int?.none, count: cellCount())
    }

    private func cellCount() -> Int {
        BoardSize.standard.size * BoardSize.standard.size
    }

    private func index(for position: Position) -> Int {
        position.row * BoardSize.standard.size + position.column
    }

    private func digits(_ values: ClosedRange<Int>) -> Set<Digit> {
        Set(values.map(Digit.init))
    }

    private func digits(_ values: [Int]) -> Set<Digit> {
        Set(values.map(Digit.init))
    }

    private struct StaticBoardSolver: BoardSolver {
        let solutionCount: Int

        func solve(_ board: Board) throws -> Board? {
            nil
        }

        func solutionCount(for board: Board, limit: Int) throws -> Int {
            solutionCount
        }
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
