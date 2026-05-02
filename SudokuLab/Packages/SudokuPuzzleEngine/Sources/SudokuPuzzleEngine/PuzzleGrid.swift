public enum PuzzleGridError: Error, Equatable, Sendable {
    case invalidCellCount(value: Int, expected: Int)
    case invalidDigit(Int)
}

public struct PuzzleGrid: Equatable, Hashable, Sendable {
    public static let size = 9
    public static let cellCount = size * size
    public static let blockSide = 3

    private let values: [Int]

    public var cells: [Int] {
        values
    }

    public init() {
        values = Array(repeating: 0, count: Self.cellCount)
    }

    public init(cells: [Int]) throws {
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

    public func value(at index: Int) -> Int {
        values[index]
    }

    public func value(row: Int, column: Int) -> Int {
        values[row * Self.size + column]
    }

    public subscript(_ index: Int) -> Int {
        value(at: index)
    }

    public subscript(row row: Int, column column: Int) -> Int {
        value(row: row, column: column)
    }

    init(uncheckedCells cells: [Int]) {
        values = cells
    }
}
