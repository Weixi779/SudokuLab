import SudokuCore
import SudokuDomain

public struct MRVBitmaskBoardSolver: BoardSolver {
    public init() {}

    public func solve(_ board: Board) throws -> Board? {
        try Self.validateSupportedBoardSize(board.boardSize)

        let grid = Self.puzzleGrid(from: board)
        guard let solution = solve(grid) else { return nil }

        return try Self.board(from: solution, preserving: board)
    }

    public func solutionCount(for board: Board, limit: Int = 2) throws -> Int {
        try Self.validateSupportedBoardSize(board.boardSize)

        return solutionCount(for: Self.puzzleGrid(from: board), limit: limit)
    }

    func solve(_ grid: PuzzleGrid) -> PuzzleGrid? {
        guard var state = SolverState(grid) else { return nil }
        guard state.solveFirst() else { return nil }

        return PuzzleGrid(uncheckedCells: state.cells)
    }

    func solutionCount(for grid: PuzzleGrid, limit: Int = 2) -> Int {
        guard limit > 0 else { return 0 }
        guard var state = SolverState(grid) else { return 0 }

        return state.solutionCount(limit: limit)
    }

    func hasUniqueSolution(_ grid: PuzzleGrid) -> Bool {
        solutionCount(for: grid, limit: 2) == 1
    }

    private static func validateSupportedBoardSize(_ boardSize: BoardSize) throws {
        guard boardSize == .standard else {
            throw BoardSolvingError.unsupportedBoardSize(boardSize)
        }
    }

    private static func puzzleGrid(from board: Board) -> PuzzleGrid {
        PuzzleGrid(
            uncheckedCells: board.positions.map { position in
                board[position].digit?.value ?? 0
            }
        )
    }

    private static func board(from solution: PuzzleGrid, preserving board: Board) throws -> Board {
        let cells = zip(board.positions, solution.cells).map { position, digit -> Cell in
            let originalCell = board[position]
            guard originalCell.digit == nil else { return originalCell }
            guard digit != 0 else { return .empty }

            return .entry(Digit(digit))
        }

        return try Board(cells: cells, boardSize: board.boardSize)
    }
}

private struct SolverState {
    private static let allCandidatesMask = (1 << StandardGrid.size) - 1

    var cells: [Int]

    private var rowMasks: [Int]
    private var columnMasks: [Int]
    private var blockMasks: [Int]

    init?(_ grid: PuzzleGrid) {
        cells = grid.cells
        rowMasks = Array(repeating: 0, count: StandardGrid.size)
        columnMasks = Array(repeating: 0, count: StandardGrid.size)
        blockMasks = Array(repeating: 0, count: StandardGrid.size)

        for index in cells.indices {
            let digit = cells[index]
            guard digit != 0 else { continue }

            let row = StandardGrid.row(forIndex: index)
            let column = StandardGrid.column(forIndex: index)
            let block = StandardGrid.block(row: row, column: column)
            let bit = Self.bit(for: digit)

            guard rowMasks[row] & bit == 0,
                columnMasks[column] & bit == 0,
                blockMasks[block] & bit == 0
            else {
                return nil
            }

            rowMasks[row] |= bit
            columnMasks[column] |= bit
            blockMasks[block] |= bit
        }
    }

    mutating func solveFirst() -> Bool {
        guard let choice = nextChoice() else { return true }
        guard choice.candidates != 0 else { return false }

        var candidates = choice.candidates

        while candidates != 0 {
            let bit = Self.lowestBit(in: candidates)
            let digit = Self.digit(for: bit)

            place(digit, at: choice.index, bit: bit)
            if solveFirst() {
                return true
            }
            remove(at: choice.index, bit: bit)

            candidates &= candidates - 1
        }

        return false
    }

    mutating func solutionCount(limit: Int) -> Int {
        countSolutions(remainingLimit: limit)
    }

    private mutating func countSolutions(remainingLimit limit: Int) -> Int {
        guard limit > 0 else { return 0 }
        guard let choice = nextChoice() else { return 1 }
        guard choice.candidates != 0 else { return 0 }

        var count = 0
        var candidates = choice.candidates

        while candidates != 0 && count < limit {
            let bit = Self.lowestBit(in: candidates)
            let digit = Self.digit(for: bit)

            place(digit, at: choice.index, bit: bit)
            count += countSolutions(remainingLimit: limit - count)
            remove(at: choice.index, bit: bit)

            candidates &= candidates - 1
        }

        return count
    }

    private func nextChoice() -> (index: Int, candidates: Int)? {
        var bestIndex: Int?
        var bestCandidates = 0
        var bestCount = Int.max

        for index in cells.indices where cells[index] == 0 {
            let candidates = candidatesMask(at: index)
            let count = candidates.nonzeroBitCount

            if count == 0 {
                return (index, 0)
            }

            if count < bestCount {
                bestIndex = index
                bestCandidates = candidates
                bestCount = count

                if count == 1 {
                    break
                }
            }
        }

        guard let bestIndex else { return nil }
        return (bestIndex, bestCandidates)
    }

    private func candidatesMask(at index: Int) -> Int {
        let row = StandardGrid.row(forIndex: index)
        let column = StandardGrid.column(forIndex: index)
        let block = StandardGrid.block(row: row, column: column)

        return Self.allCandidatesMask & ~(rowMasks[row] | columnMasks[column] | blockMasks[block])
    }

    private mutating func place(_ digit: Int, at index: Int, bit: Int) {
        let row = StandardGrid.row(forIndex: index)
        let column = StandardGrid.column(forIndex: index)
        let block = StandardGrid.block(row: row, column: column)

        cells[index] = digit
        rowMasks[row] |= bit
        columnMasks[column] |= bit
        blockMasks[block] |= bit
    }

    private mutating func remove(at index: Int, bit: Int) {
        let row = StandardGrid.row(forIndex: index)
        let column = StandardGrid.column(forIndex: index)
        let block = StandardGrid.block(row: row, column: column)

        cells[index] = 0
        rowMasks[row] &= ~bit
        columnMasks[column] &= ~bit
        blockMasks[block] &= ~bit
    }

    private static func bit(for digit: Int) -> Int {
        1 << (digit - 1)
    }

    private static func digit(for bit: Int) -> Int {
        bit.trailingZeroBitCount + 1
    }

    private static func lowestBit(in mask: Int) -> Int {
        mask & -mask
    }
}
