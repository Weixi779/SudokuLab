import SudokuCore

public struct BoardTopology: Equatable, Sendable {
    public let size: BoardSize
    public let positions: [Position]
    public let rows: [[Position]]
    public let columns: [[Position]]
    public let blocks: [[Position]]

    public init(size: BoardSize = .standard) {
        let indices = size.positionIndices
        let rows = Self.makeRows(indices: indices)

        self.size = size
        self.rows = rows
        positions = rows.flatMap { $0 }
        columns = Self.makeColumns(indices: indices)
        blocks = Self.makeBlocks(indices: indices, blockSide: size.blockSide)
    }

    public func contains(_ position: Position) -> Bool {
        contains(position.row) && contains(position.column)
    }

    public func index(for position: Position) throws -> Int {
        guard contains(position) else {
            throw BoardError.invalidPosition(position)
        }

        return uncheckedIndex(for: position)
    }

    public func uncheckedIndex(for position: Position) -> Int {
        position.row * size.sideLength + position.column
    }

    public func position(at index: Int) -> Position? {
        guard (0..<size.cellCount).contains(index) else { return nil }

        return Position(row: row(forIndex: index), column: column(forIndex: index))
    }

    public func row(forIndex index: Int) -> Int {
        index / size.sideLength
    }

    public func column(forIndex index: Int) -> Int {
        index % size.sideLength
    }

    public func block(row: Int, column: Int) -> Int {
        (row / size.blockSide) * size.blockSide + column / size.blockSide
    }

    private func contains(_ index: Int) -> Bool {
        index >= 0 && index < size.sideLength
    }

    private static func makeRows(indices: Range<Int>) -> [[Position]] {
        return indices.map { row in
            indices.map { column in
                Position(row: row, column: column)
            }
        }
    }

    private static func makeColumns(indices: Range<Int>) -> [[Position]] {
        return indices.map { column in
            indices.map { row in
                Position(row: row, column: column)
            }
        }
    }

    private static func makeBlocks(indices: Range<Int>, blockSide: Int) -> [[Position]] {
        indices.map { block in
            let firstRow = (block / blockSide) * blockSide
            let firstColumn = (block % blockSide) * blockSide

            return (firstRow..<(firstRow + blockSide)).flatMap { row in
                (firstColumn..<(firstColumn + blockSide)).map { column in
                    Position(row: row, column: column)
                }
            }
        }
    }
}
