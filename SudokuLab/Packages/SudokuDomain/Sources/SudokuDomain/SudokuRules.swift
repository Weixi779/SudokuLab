import SudokuCore

public struct SudokuRules: Sendable {
    public init() {}

    public func validate(_ grid: SudokuGrid) -> [SudokuRuleViolation] {
        StandardGrid.ruleGroups.flatMap { positions in
            duplicateDigits(in: positions, grid: grid)
        }
    }

    private func duplicateDigits(in group: [Position], grid: SudokuGrid)
        -> [SudokuRuleViolation]
    {
        var positionsByDigit: [Digit: [Position]] = [:]

        for position in group {
            guard let digit = grid[position].digit else { continue }
            positionsByDigit[digit, default: []].append(position)
        }

        return positionsByDigit.keys.sorted().compactMap { digit in
            let positions = positionsByDigit[digit, default: []].sorted()
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(digit, positions: positions)
        }
    }
}
