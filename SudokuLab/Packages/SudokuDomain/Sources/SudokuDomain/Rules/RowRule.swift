import SudokuCore

public struct RowRule: Rule, Equatable, Hashable, Sendable {
    public let row: Int
    public let positions: [Position]

    public init(row: Int, on board: Board) {
        self.row = row
        positions = board[row: row]
    }

    public func validate(_ board: Board) -> [Violation] {
        var positionsByDigit: [Digit: [Position]] = [:]

        for position in positions where board.contains(position) {
            guard let digit = board[position].digit else { continue }
            positionsByDigit[digit, default: []].append(position)
        }

        return positionsByDigit.keys.sorted().compactMap { digit in
            let positions = positionsByDigit[digit, default: []].sorted()
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(digit, positions: positions)
        }
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
        Set((1...board.size.size).map(Digit.init))
    }
}
