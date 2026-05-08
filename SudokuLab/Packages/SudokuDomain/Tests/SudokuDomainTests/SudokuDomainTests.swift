import SudokuCore
import SudokuDomain
import Testing

@Suite
struct SudokuDomainTests {
    @Test func emptyBoardHasExpectedCells() throws {
        let board = Board()
        let boardSize = BoardSize.standard

        #expect(board.boardSize == boardSize)
        #expect(board.cellCount == 81)
        #expect(boardSize.size == 9)
        #expect(boardSize.blockSide == 3)
        #expect(board[Position(row: 0, column: 0)] == .empty)
        #expect(try board.cell(at: Position(row: 8, column: 8)) == .empty)
    }

    @Test func boardUsesInjectedBoardSize() throws {
        let boardSize = BoardSize(size: 4, blockSide: 2)
        var cells = emptyCells(for: boardSize)
        cells[index(for: Position(row: 3, column: 3), boardSize: boardSize)] = .entry(Digit(4))

        let board = try Board(cells: cells, boardSize: boardSize)

        #expect(board.boardSize == boardSize)
        #expect(board.cellCount == 16)
        #expect(try board.cell(at: Position(row: 3, column: 3)) == .entry(Digit(4)))
    }

    @Test func boardPositionsUseRowMajorOrder() throws {
        let board = try Board(boardSize: BoardSize(size: 4, blockSide: 2))

        #expect(
            board.positions.prefix(5) == [
                Position(row: 0, column: 0),
                Position(row: 0, column: 1),
                Position(row: 0, column: 2),
                Position(row: 0, column: 3),
                Position(row: 1, column: 0),
            ])
        #expect(board.positions.last == Position(row: 3, column: 3))
    }

    @Test func boardContainsPositionsAndDigitsInsideBoardSize() throws {
        let board = try Board(boardSize: BoardSize(size: 4, blockSide: 2))

        #expect(board.contains(Position(row: 0, column: 0)))
        #expect(board.contains(Position(row: 3, column: 3)))
        #expect(!board.contains(Position(row: 4, column: 0)))
        #expect(!board.contains(Position(row: 0, column: 4)))

        #expect(board.contains(Digit(1)))
        #expect(board.contains(Digit(4)))
        #expect(!board.contains(Digit(0)))
        #expect(!board.contains(Digit(5)))
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

    @Test func boardGenerationConfigurationDefaultToStandardLocallyMinimal() {
        let configuration = BoardGenerationConfiguration()

        #expect(configuration.boardSize == .standard)
        #expect(configuration.goal == .locallyMinimal)
    }

    @Test func rulesUseBoardSizeConstraints() throws {
        let boardSize = BoardSize(size: 4, blockSide: 2)
        var clues = emptyClues(for: boardSize)
        clues[index(for: Position(row: 2, column: 2), boardSize: boardSize)] = 4
        clues[index(for: Position(row: 3, column: 3), boardSize: boardSize)] = 4
        let board = try Board(clues: clues, boardSize: boardSize)

        #expect(
            SudokuRules().validate(board) == [
                .duplicateDigit(
                    Digit(4),
                    positions: [
                        Position(row: 2, column: 2),
                        Position(row: 3, column: 3),
                    ]
                )
            ]
        )
    }

    @Test func boardSizeRejectsInvalidShape() {
        let boardSize = BoardSize(size: 6, blockSide: 2)

        #expect(throws: SudokuDomainError.invalidBoardSize(size: 6, blockSide: 2)) {
            try Board(boardSize: boardSize)
        }
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

    @Test func boardRejectsDigitsOutsideBoardSize() throws {
        let boardSize = BoardSize(size: 4, blockSide: 2)
        var cells = emptyCells(for: boardSize)
        cells[index(for: Position(row: 0, column: 0), boardSize: boardSize)] = .entry(Digit(5))

        #expect(throws: SudokuDomainError.invalidDigit(value: 5, maximum: 4)) {
            try Board(cells: cells, boardSize: boardSize)
        }

        var clues = emptyClues(for: boardSize)
        clues[index(for: Position(row: 0, column: 0), boardSize: boardSize)] = 5

        #expect(throws: SudokuDomainError.invalidDigit(value: 5, maximum: 4)) {
            try Board(clues: clues, boardSize: boardSize)
        }

        var board = try Board(boardSize: boardSize)

        #expect(throws: SudokuDomainError.invalidDigit(value: 5, maximum: 4)) {
            try board.setEntry(Digit(5), at: Position(row: 0, column: 0))
        }
    }

    @Test func boardRejectsPositionsOutsideBoardSize() throws {
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
        let boardSize = BoardSize.standard
        var clues = emptyClues(for: boardSize)

        for (rowIndex, columnIndex, value) in entries {
            clues[index(for: Position(row: rowIndex, column: columnIndex), boardSize: boardSize)] =
                value
        }

        return clues
    }

    private func emptyCells(for boardSize: BoardSize = .standard) -> [Cell] {
        Array(repeating: .empty, count: cellCount(for: boardSize))
    }

    private func emptyClues(for boardSize: BoardSize = .standard) -> [Int?] {
        Array(repeating: Int?.none, count: cellCount(for: boardSize))
    }

    private func cellCount(for boardSize: BoardSize = .standard) -> Int {
        boardSize.size * boardSize.size
    }

    private func index(for position: Position, boardSize: BoardSize = .standard) -> Int {
        position.row * boardSize.size + position.column
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
