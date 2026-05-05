import SudokuCore

public struct SudokuGrid: Equatable, Sendable {
    public static let size = StandardGrid.size
    public static let cellCount = StandardGrid.cellCount
    public static let blockSide = StandardGrid.blockSide

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

    public subscript(_ position: Position) -> SudokuCell {
        cells[index(for: position)]
    }

    public func cell(at position: Position) -> SudokuCell {
        self[position]
    }

    public mutating func setEntry(_ digit: Digit?, at position: Position) throws {
        let cell = self[position]

        guard !cell.isClue else {
            throw SudokuDomainError.cannotChangeClue(position)
        }

        cells[index(for: position)] = digit.map(SudokuCell.entry) ?? .empty
    }

    private func index(for position: Position) -> Int {
        StandardGrid.index(for: position)
    }
}
