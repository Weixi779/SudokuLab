import SudokuCore

public struct BlockRule: Rule, Equatable, Hashable, Sendable {
    public let block: Int
    public let positions: [Position]

    public init(block: Int, on board: Board) {
        self.block = block
        positions = board[block: block]
    }

    public func validate(_ board: Board) -> [Violation] {
        DuplicateDigitScanner.violations(in: positions, on: board)
    }

    public func candidates(at position: Position, on board: Board) -> Set<Digit>? {
        guard positions.contains(position) else { return nil }
        guard board.contains(position) else { return [] }
        guard board[position].digit == nil else { return [] }

        let usedDigits: Set<Digit> = Set(
            positions.compactMap { position in
                guard board.contains(position) else { return nil }
                return board[position].digit
            }
        )

        return digits(for: board).subtracting(usedDigits)
    }

    private func digits(for board: Board) -> Set<Digit> {
        Set(board.size.digitValues.map(Digit.init))
    }
}
