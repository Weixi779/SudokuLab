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
        var positionsByDigit: [Digit: [Position]] = [:]

        for position in house.positions {
            let digit = grid[row: position.row, column: position.column]
            guard digit != 0 else { continue }
            positionsByDigit[Digit(digit), default: []].append(position)
        }

        return positionsByDigit.keys.sorted().compactMap { digit in
            let positions = positionsByDigit[digit, default: []].sorted()
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(digit: digit, house: house, positions: positions)
        }
    }

    static func emptyPositions(in grid: PuzzleGrid) -> [Position] {
        var positions: [Position] = []

        for index in grid.cells.indices where grid[index] == 0 {
            positions.append(
                Position(
                    row: SudokuLayout.rowIndex(forSquareIndex: index),
                    column: SudokuLayout.columnIndex(forSquareIndex: index)
                )
            )
        }

        return positions
    }
}
