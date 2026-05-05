import SudokuCore

public struct SudokuRules: Sendable {
    public init() {}

    public func validate(_ grid: SudokuGrid) -> [SudokuRuleViolation] {
        SudokuHouse.all.flatMap { house in
            duplicateDigits(in: house, grid: grid)
        }
    }

    private func duplicateDigits(in house: SudokuHouse, grid: SudokuGrid)
        -> [SudokuRuleViolation]
    {
        var positionsByDigit: [Digit: [Position]] = [:]

        for position in house.positions {
            guard let digit = grid[position].digit else { continue }
            positionsByDigit[digit, default: []].append(position)
        }

        return positionsByDigit.keys.sorted().compactMap { digit in
            let positions = positionsByDigit[digit, default: []].sorted()
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(digit, house: house, positions: positions)
        }
    }
}
