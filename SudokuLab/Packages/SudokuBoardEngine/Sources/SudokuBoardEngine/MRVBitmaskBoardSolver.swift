import SudokuCore
import SudokuDomain

public struct MRVBitmaskBoardSolver: BoardSolver {
    public init() {}

    public func solve(_ board: Board) throws -> Board? {
        let digits = BoardDigits(board: board)
        guard let solution = solve(digits) else { return nil }

        return try Self.board(from: solution, preserving: board)
    }

    public func solutionCount(for board: Board, limit: Int = 2) throws -> Int {
        return solutionCount(for: BoardDigits(board: board), limit: limit)
    }

    func solve(_ digits: BoardDigits) -> BoardDigits? {
        guard var state = SolverState(digits) else { return nil }
        guard state.solveFirst() else { return nil }

        return BoardDigits(uncheckedDigits: state.digits)
    }

    func solutionCount(for digits: BoardDigits, limit: Int = 2) -> Int {
        guard limit > 0 else { return 0 }
        guard var state = SolverState(digits) else { return 0 }

        return state.solutionCount(limit: limit)
    }

    private static func board(from solution: BoardDigits, preserving board: Board) throws -> Board {
        let cells = zip(board.positions, solution.digits).map { position, digit -> Cell in
            let originalCell = board[position]
            guard originalCell.digit == nil else { return originalCell }
            guard digit != 0 else { return .empty }

            return .entry(Digit(digit))
        }

        return try Board(cells: cells)
    }
}

private struct SolverState {
    private static let allCandidatesMask = (1 << BoardDigits.size) - 1

    var digits: [Int]

    private var rowMasks: [Int]
    private var columnMasks: [Int]
    private var blockMasks: [Int]

    init?(_ digits: BoardDigits) {
        self.digits = digits.digits
        rowMasks = Array(repeating: 0, count: BoardDigits.size)
        columnMasks = Array(repeating: 0, count: BoardDigits.size)
        blockMasks = Array(repeating: 0, count: BoardDigits.size)

        for index in self.digits.indices {
            let digit = self.digits[index]
            guard digit != 0 else { continue }

            let row = BoardDigits.topology.row(forIndex: index)
            let column = BoardDigits.topology.column(forIndex: index)
            let block = BoardDigits.topology.block(row: row, column: column)
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

        for index in digits.indices where digits[index] == 0 {
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
        let row = BoardDigits.topology.row(forIndex: index)
        let column = BoardDigits.topology.column(forIndex: index)
        let block = BoardDigits.topology.block(row: row, column: column)

        return Self.allCandidatesMask & ~(rowMasks[row] | columnMasks[column] | blockMasks[block])
    }

    private mutating func place(_ digit: Int, at index: Int, bit: Int) {
        let row = BoardDigits.topology.row(forIndex: index)
        let column = BoardDigits.topology.column(forIndex: index)
        let block = BoardDigits.topology.block(row: row, column: column)

        digits[index] = digit
        rowMasks[row] |= bit
        columnMasks[column] |= bit
        blockMasks[block] |= bit
    }

    private mutating func remove(at index: Int, bit: Int) {
        let row = BoardDigits.topology.row(forIndex: index)
        let column = BoardDigits.topology.column(forIndex: index)
        let block = BoardDigits.topology.block(row: row, column: column)

        digits[index] = 0
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
