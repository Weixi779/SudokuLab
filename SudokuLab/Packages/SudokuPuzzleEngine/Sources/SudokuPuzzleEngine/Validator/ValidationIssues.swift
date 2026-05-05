import SudokuCore

enum ValidationIssues {
    static func duplicateIssues(in grid: PuzzleGrid) -> [ValidationIssue] {
        SudokuHouse.all.flatMap { house in
            duplicateIssues(in: house, grid: grid)
        }
    }

    private static func duplicateIssues(in house: SudokuHouse, grid: PuzzleGrid)
        -> [ValidationIssue]
    {
        var squaresByDigit: [Digit: [SudokuSquare]] = [:]

        for square in house.squares {
            let digit = grid[square.rawValue]
            guard digit != 0 else { continue }
            squaresByDigit[Digit(digit), default: []].append(square)
        }

        return squaresByDigit.keys.sorted().compactMap { digit in
            let squares = squaresByDigit[digit, default: []].sorted()
            guard squares.count > 1 else { return nil }
            return .duplicateDigit(digit: digit, house: house, squares: squares)
        }
    }

    static func emptySquares(in grid: PuzzleGrid) -> [SudokuSquare] {
        var squares: [SudokuSquare] = []

        for index in grid.cells.indices where grid[index] == 0 {
            guard let square = try? SudokuSquare(index) else { continue }
            squares.append(square)
        }

        return squares
    }
}
