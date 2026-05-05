import SudokuCore

enum StandardGrid {
    static let size = 9
    static let cellCount = size * size
    static let blockSide = 3

    static let ruleGroups: [[Position]] =
        (0..<size).map(row)
        + (0..<size).map(column)
        + (0..<size).map(block)

    static func index(for position: Position) -> Int {
        position.row * size + position.column
    }

    private static func row(_ row: Int) -> [Position] {
        (0..<size).map { column in
            Position(row: row, column: column)
        }
    }

    private static func column(_ column: Int) -> [Position] {
        (0..<size).map { row in
            Position(row: row, column: column)
        }
    }

    private static func block(_ block: Int) -> [Position] {
        let firstRow = (block / blockSide) * blockSide
        let firstColumn = (block % blockSide) * blockSide

        return (firstRow..<(firstRow + blockSide)).flatMap { row in
            (firstColumn..<(firstColumn + blockSide)).map { column in
                Position(row: row, column: column)
            }
        }
    }
}
