import SudokuCore

public struct SudokuGrid: Equatable, Sendable {
    public static let size = SudokuLayout.size
    public static let cellCount = SudokuLayout.cellCount
    public static let blockSide = SudokuLayout.blockSide

    private var cells: [SudokuCell]

    public init() {
        cells = Array(repeating: .empty, count: Self.cellCount)
    }

    public init(cells: [SudokuCell]) throws {
        guard cells.count == Self.cellCount else {
            throw SudokuDomainError.invalidCellCount(value: cells.count, expected: Self.cellCount)
        }

        self.cells = cells
    }

    public init(clues: [Int?]) throws {
        guard clues.count == Self.cellCount else {
            throw SudokuDomainError.invalidCellCount(value: clues.count, expected: Self.cellCount)
        }

        cells = clues.map { value in
            guard let value else { return .empty }
            return .clue(Digit(value))
        }
    }

    public subscript(_ square: SudokuSquare) -> SudokuCell {
        cells[square.rawValue]
    }

    public func cell(at square: SudokuSquare) -> SudokuCell {
        self[square]
    }

    public mutating func setEntry(_ digit: Digit?, at square: SudokuSquare) throws {
        let cell = self[square]

        guard !cell.isClue else {
            throw SudokuDomainError.cannotChangeClue(square)
        }

        cells[square.rawValue] = digit.map(SudokuCell.entry) ?? .empty
    }
}
