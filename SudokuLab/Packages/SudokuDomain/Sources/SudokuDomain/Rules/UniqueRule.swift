import SudokuCore

public struct UniqueRule: Rule, Sendable {
    public let rowsRule: RowsRule
    public let columnsRule: ColumnsRule
    public let blocksRule: BlocksRule

    public init(board: Board) {
        rowsRule = RowsRule(board: board)
        columnsRule = ColumnsRule(board: board)
        blocksRule = BlocksRule(board: board)
    }

    public func validate(_ board: Board) -> [Violation] {
        uniqued(
            rowsRule.validate(board)
                + columnsRule.validate(board)
                + blocksRule.validate(board)
        )
    }

    public func candidates(at position: Position, on board: Board) -> Set<Digit>? {
        guard board.contains(position) else { return [] }
        guard board[position].digit == nil else { return [] }

        var candidates: Set<Digit>?

        for rule in [rowsRule, columnsRule, blocksRule] as [any Rule] {
            guard let ruleCandidates = rule.candidates(at: position, on: board) else {
                continue
            }

            candidates = candidates.map { $0.intersection(ruleCandidates) } ?? ruleCandidates
        }

        return candidates ?? digits(for: board)
    }

    private func uniqued(_ violations: [Violation]) -> [Violation] {
        var seen: Set<Violation> = []
        var result: [Violation] = []

        for violation in violations where seen.insert(violation).inserted {
            result.append(violation)
        }

        return result
    }

    private func digits(for board: Board) -> Set<Digit> {
        Set((1...board.size.size).map(Digit.init))
    }
}
