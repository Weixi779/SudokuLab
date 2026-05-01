public struct SudokuDigit: Equatable, Hashable, Comparable, Sendable {
    public static let all: [SudokuDigit] = (1...SudokuGrid.size).map { rawValue in
        SudokuDigit(uncheckedRawValue: rawValue)
    }

    public let rawValue: Int

    public init(_ rawValue: Int) throws {
        guard (1...SudokuGrid.size).contains(rawValue) else {
            throw SudokuError.invalidDigit(rawValue)
        }

        self.rawValue = rawValue
    }

    public static func < (lhs: SudokuDigit, rhs: SudokuDigit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    init(uncheckedRawValue rawValue: Int) {
        self.rawValue = rawValue
    }
}
