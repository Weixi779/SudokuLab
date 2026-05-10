import SudokuCore

public struct RowsRule: Rule, Sendable {
    public let rules: [RowRule]

    public init(board: Board) {
        rules = board.size.positionIndices.map { row in
            RowRule(row: row, on: board)
        }
    }

    public func validate(_ board: Board) -> [Violation] {
        rules.flatMap { $0.validate(board) }
    }

    public func candidates(at position: Position, on board: Board) -> Set<Digit>? {
        guard board.contains(position) else { return [] }

        return rules.lazy
            .compactMap { $0.candidates(at: position, on: board) }
            .first
    }
}
