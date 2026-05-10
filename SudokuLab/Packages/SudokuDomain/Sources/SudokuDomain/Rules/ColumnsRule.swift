import SudokuCore

public struct ColumnsRule: Rule, Sendable {
    public let rules: [ColumnRule]

    public init(board: Board) {
        rules = (0..<board.size.size).map { column in
            ColumnRule(column: column, on: board)
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
