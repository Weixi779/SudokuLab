public struct SudokuGrid: Equatable, Sendable {
    public static let size = 9
    public static let cellCount = size * size
    public static let blockSide = 3

    private var cells: [SudokuCell]

    public init() {
        cells = Array(repeating: .empty, count: Self.cellCount)
    }

    public init(cells: [SudokuCell]) throws {
        guard cells.count == Self.cellCount else {
            throw SudokuError.invalidCellCount(value: cells.count, expected: Self.cellCount)
        }

        self.cells = cells
    }

    public init(clues: [Int?]) throws {
        guard clues.count == Self.cellCount else {
            throw SudokuError.invalidCellCount(value: clues.count, expected: Self.cellCount)
        }

        cells = try clues.map { rawValue in
            guard let rawValue else { return .empty }
            return .clue(try SudokuDigit(rawValue))
        }
    }

    public subscript(_ square: SudokuSquare) -> SudokuCell {
        cells[square.rawValue]
    }

    public func cell(at square: SudokuSquare) -> SudokuCell {
        self[square]
    }

    public mutating func setEntry(_ digit: SudokuDigit?, at square: SudokuSquare) throws {
        let cell = self[square]

        guard !cell.isClue else {
            throw SudokuError.cannotChangeClue(square)
        }

        cells[square.rawValue] = digit.map(SudokuCell.entry) ?? .empty
    }
}
