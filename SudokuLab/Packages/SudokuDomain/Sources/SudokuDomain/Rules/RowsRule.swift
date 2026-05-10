import SudokuCore

public struct RowsRule: Rule, Sendable {
    public let rules: [RowRule]

    public init(board: Board) {
        rules = (0..<board.size.size).map { row in
            RowRule(row: row, on: board)
        }
    }

    public func validate(_ board: Board) -> [Violation] {
        rules.flatMap { rule in
            rule.validate(board)
        }
    }

    public func candidates(at position: Position, on board: Board) -> Set<Digit>? {
        guard board.contains(position) else { return [] }

        for rule in rules {
            guard let candidates = rule.candidates(at: position, on: board) else {
                continue
            }

            return candidates
        }

        return nil
    }
}
