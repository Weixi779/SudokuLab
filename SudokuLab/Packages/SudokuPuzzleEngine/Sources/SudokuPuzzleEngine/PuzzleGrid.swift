import SudokuCore

enum PuzzleGridError: Error, Equatable, Sendable {
    case invalidCellCount(value: Int, expected: Int)
    case invalidDigit(Int)
}

struct PuzzleGrid: Equatable, Hashable, Sendable {
    static let size = StandardGrid.size
    static let cellCount = StandardGrid.cellCount
    static let blockSide = StandardGrid.blockSide

    private let values: [Int]

    var cells: [Int] {
        values
    }

    init() {
        values = Array(repeating: 0, count: Self.cellCount)
    }

    init(cells: [Int]) throws {
        guard cells.count == Self.cellCount else {
            throw PuzzleGridError.invalidCellCount(value: cells.count, expected: Self.cellCount)
        }

        for value in cells {
            guard (0...Self.size).contains(value) else {
                throw PuzzleGridError.invalidDigit(value)
            }
        }

        values = cells
    }

    func value(at index: Int) -> Int {
        values[index]
    }

    func value(row: Int, column: Int) -> Int {
        values[StandardGrid.index(row: row, column: column)]
    }

    subscript(_ index: Int) -> Int {
        value(at: index)
    }

    subscript(row row: Int, column column: Int) -> Int {
        value(row: row, column: column)
    }

    init(uncheckedCells cells: [Int]) {
        values = cells
    }
}
