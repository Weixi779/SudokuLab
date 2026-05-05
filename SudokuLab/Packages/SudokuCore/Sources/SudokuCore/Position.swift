public struct Position: Equatable, Hashable, Comparable, Sendable {
    public let row: Int
    public let column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    public static func < (lhs: Position, rhs: Position) -> Bool {
        (lhs.row, lhs.column) < (rhs.row, rhs.column)
    }
}
