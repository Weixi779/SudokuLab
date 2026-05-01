public struct SudokuRules: Sendable {
    public init() {}

    public func validate(_ grid: SudokuGrid) -> [SudokuRuleViolation] {
        SudokuHouse.all.flatMap { house in
            duplicateViolations(in: house, grid: grid)
        }
    }

    private func duplicateViolations(in house: SudokuHouse, grid: SudokuGrid)
        -> [SudokuRuleViolation]
    {
        var squaresByDigit: [SudokuDigit: [SudokuSquare]] = [:]

        for square in house.squares {
            guard let digit = grid[square].digit else { continue }
            squaresByDigit[digit, default: []].append(square)
        }

        return squaresByDigit.keys.sorted().compactMap { digit in
            let squares = squaresByDigit[digit, default: []].sorted()
            guard squares.count > 1 else { return nil }
            return .duplicateDigit(digit, house: house, squares: squares)
        }
    }
}
