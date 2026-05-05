import SudokuCore

enum ValidationIssues {
    static func duplicateIssues(in grid: PuzzleGrid) -> [ValidationIssue] {
        SudokuDuplicateScanner.duplicates { square in
            let digit = grid[square.rawValue]
            guard digit != 0 else { return nil }
            return Digit(digit)
        }.map { duplicate in
            .duplicateDigit(
                digit: duplicate.digit,
                house: duplicate.house,
                squares: duplicate.squares
            )
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
