import SudokuCore

enum ValidationIssues {
    static func duplicateIssues(in grid: PuzzleGrid) -> [ValidationIssue] {
        StandardGrid.ruleGroups.flatMap { positions in
            duplicateIssues(in: positions, grid: grid)
        }
    }

    private static func duplicateIssues(in group: [Position], grid: PuzzleGrid)
        -> [ValidationIssue]
    {
        var positionsByDigit: [Digit: [Position]] = [:]

        for position in group {
            let digit = grid[row: position.row, column: position.column]
            guard digit != 0 else { continue }
            positionsByDigit[Digit(digit), default: []].append(position)
        }

        return positionsByDigit.keys.sorted().compactMap { digit in
            let positions = positionsByDigit[digit, default: []].sorted()
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(digit: digit, positions: positions)
        }
    }

    static func emptyPositions(in grid: PuzzleGrid) -> [Position] {
        var positions: [Position] = []

        for index in grid.cells.indices where grid[index] == 0 {
            positions.append(
                Position(
                    row: StandardGrid.row(forIndex: index),
                    column: StandardGrid.column(forIndex: index)
                )
            )
        }

        return positions
    }
}
