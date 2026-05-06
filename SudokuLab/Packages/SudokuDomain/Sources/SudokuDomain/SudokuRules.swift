import SudokuCore

public struct SudokuRules: Sendable {
    public init() {}

    public func validate(_ board: Board) -> [SudokuRuleViolation] {
        board.constraintGroups.flatMap { positions in
            duplicateDigits(in: positions, board: board)
        }
    }

    private func duplicateDigits(in group: [Position], board: Board)
        -> [SudokuRuleViolation]
    {
        var positionsByDigit: [Digit: [Position]] = [:]

        for position in group {
            guard let digit = board[position].digit else { continue }
            positionsByDigit[digit, default: []].append(position)
        }

        return positionsByDigit.keys.sorted().compactMap { digit in
            let positions = positionsByDigit[digit, default: []].sorted()
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(digit, positions: positions)
        }
    }
}
