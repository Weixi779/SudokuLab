import SudokuCore

public struct UniqueRule: Rule, Sendable {
    public let rowsRule: RowsRule
    public let columnsRule: ColumnsRule
    public let blocksRule: BlocksRule

    private let rules: RuleGroup

    public init(board: Board) {
        let rowsRule = RowsRule(board: board)
        let columnsRule = ColumnsRule(board: board)
        let blocksRule = BlocksRule(board: board)

        self.rowsRule = rowsRule
        self.columnsRule = columnsRule
        self.blocksRule = blocksRule
        rules = RuleGroup([rowsRule, columnsRule, blocksRule])
    }

    public func validate(_ board: Board) -> [Violation] {
        rules.validate(board)
    }

    public func candidates(at position: Position, on board: Board) -> Set<Digit>? {
        guard board.contains(position) else { return [] }
        guard board[position].digit == nil else { return [] }

        return rules.candidates(at: position, on: board) ?? digits(for: board)
    }

    private func digits(for board: Board) -> Set<Digit> {
        Set((1...board.size.size).map(Digit.init))
    }

    private struct RuleGroup: Sendable {
        private let rules: [any Rule]

        init(_ rules: [any Rule]) {
            self.rules = rules
        }

        func validate(_ board: Board) -> [Violation] {
            uniqued(rules.flatMap { $0.validate(board) })
        }

        func candidates(at position: Position, on board: Board) -> Set<Digit>? {
            var candidates: Set<Digit>?

            for rule in rules {
                guard let ruleCandidates = rule.candidates(at: position, on: board) else {
                    continue
                }

                candidates = candidates.map { $0.intersection(ruleCandidates) } ?? ruleCandidates
            }

            return candidates
        }

        private func uniqued(_ violations: [Violation]) -> [Violation] {
            var seen: Set<Violation> = []
            var result: [Violation] = []

            for violation in violations where seen.insert(violation).inserted {
                result.append(violation)
            }

            return result
        }
    }
}
