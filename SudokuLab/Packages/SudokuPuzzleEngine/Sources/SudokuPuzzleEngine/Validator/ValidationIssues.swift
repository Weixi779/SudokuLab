enum ValidationIssues {
    static func duplicateIssues(in grid: PuzzleGrid) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        issues.reserveCapacity(PuzzleGrid.size * 3)

        for unitCells in PuzzleUnitCells.all {
            appendDuplicateIssues(in: unitCells, grid: grid, to: &issues)
        }

        return issues
    }

    static func emptyCellIndices(in grid: PuzzleGrid) -> [Int] {
        var cellIndices: [Int] = []

        for index in grid.cells.indices where grid[index] == 0 {
            cellIndices.append(index)
        }

        return cellIndices
    }

    private static func appendDuplicateIssues(
        in unitCells: PuzzleUnitCells,
        grid: PuzzleGrid,
        to issues: inout [ValidationIssue]
    ) {
        var cellIndicesByDigit = Array(repeating: [Int](), count: PuzzleGrid.size + 1)

        for cellIndex in unitCells.cellIndices {
            let digit = grid[cellIndex]
            guard digit != 0 else { continue }

            cellIndicesByDigit[digit].append(cellIndex)
        }

        for digit in 1...PuzzleGrid.size {
            let cellIndices = cellIndicesByDigit[digit]
            guard cellIndices.count > 1 else { continue }

            issues.append(
                .duplicateDigit(
                    digit: digit,
                    unit: unitCells.unit,
                    cellIndices: cellIndices
                )
            )
        }
    }
}

private struct PuzzleUnitCells: Sendable {
    static let all: [PuzzleUnitCells] = {
        var unitCells: [PuzzleUnitCells] = []
        unitCells.reserveCapacity(PuzzleGrid.size * 3)

        for row in 0..<PuzzleGrid.size {
            unitCells.append(
                PuzzleUnitCells(
                    unit: PuzzleUnit(uncheckedKind: .row, index: row),
                    cellIndices: rowCellIndices(row)
                )
            )
        }

        for column in 0..<PuzzleGrid.size {
            unitCells.append(
                PuzzleUnitCells(
                    unit: PuzzleUnit(uncheckedKind: .column, index: column),
                    cellIndices: columnCellIndices(column)
                )
            )
        }

        for block in 0..<PuzzleGrid.size {
            unitCells.append(
                PuzzleUnitCells(
                    unit: PuzzleUnit(uncheckedKind: .block, index: block),
                    cellIndices: blockCellIndices(block)
                )
            )
        }

        return unitCells
    }()

    let unit: PuzzleUnit
    let cellIndices: [Int]

    private static func rowCellIndices(_ row: Int) -> [Int] {
        var cellIndices: [Int] = []
        cellIndices.reserveCapacity(PuzzleGrid.size)

        for column in 0..<PuzzleGrid.size {
            cellIndices.append(row * PuzzleGrid.size + column)
        }

        return cellIndices
    }

    private static func columnCellIndices(_ column: Int) -> [Int] {
        var cellIndices: [Int] = []
        cellIndices.reserveCapacity(PuzzleGrid.size)

        for row in 0..<PuzzleGrid.size {
            cellIndices.append(row * PuzzleGrid.size + column)
        }

        return cellIndices
    }

    private static func blockCellIndices(_ block: Int) -> [Int] {
        let firstRow = (block / PuzzleGrid.blockSide) * PuzzleGrid.blockSide
        let firstColumn = (block % PuzzleGrid.blockSide) * PuzzleGrid.blockSide
        var cellIndices: [Int] = []
        cellIndices.reserveCapacity(PuzzleGrid.size)

        for row in firstRow..<(firstRow + PuzzleGrid.blockSide) {
            for column in firstColumn..<(firstColumn + PuzzleGrid.blockSide) {
                cellIndices.append(row * PuzzleGrid.size + column)
            }
        }

        return cellIndices
    }
}
