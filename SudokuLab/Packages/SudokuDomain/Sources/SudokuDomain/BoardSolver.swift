import SudokuCore

public protocol BoardSolver: Sendable {
    func solve(_ board: Board) throws -> Board?
    func solutionCount(for board: Board, limit: Int) throws -> Int
}

extension BoardSolver {
    public func hasUniqueSolution(_ board: Board) throws -> Bool {
        try solutionCount(for: board, limit: 2) == 1
    }
}

public enum BoardSolvingError: Error, Equatable, Sendable {
    case unsupportedBoardSize(BoardSize)
}
