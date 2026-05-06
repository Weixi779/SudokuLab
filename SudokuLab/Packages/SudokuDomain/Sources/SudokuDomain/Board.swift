import SudokuCore

public struct Board: Equatable, Sendable {
    public let boardSize: BoardSize
    private var cells: [Cell]

    public init() {
        boardSize = .standard
        cells = Array(repeating: .empty, count: Self.cellCount(for: boardSize))
    }

    public init(boardSize: BoardSize) throws {
        try Self.validate(boardSize)

        self.boardSize = boardSize
        cells = Array(repeating: .empty, count: Self.cellCount(for: boardSize))
    }

    public init(cells: [Cell], boardSize: BoardSize = .standard) throws {
        try Self.validate(boardSize)

        guard cells.count == Self.cellCount(for: boardSize) else {
            throw SudokuDomainError.invalidCellCount(
                value: cells.count,
                expected: Self.cellCount(for: boardSize)
            )
        }

        try Self.validate(cells, boardSize: boardSize)

        self.boardSize = boardSize
        self.cells = cells
    }

    public init(clues: [Int?], boardSize: BoardSize = .standard) throws {
        try Self.validate(boardSize)

        guard clues.count == Self.cellCount(for: boardSize) else {
            throw SudokuDomainError.invalidCellCount(
                value: clues.count,
                expected: Self.cellCount(for: boardSize)
            )
        }

        self.boardSize = boardSize
        cells = try clues.map { value in
            guard let value else { return .empty }
            let digit = Digit(value)
            try Self.validate(digit, boardSize: boardSize)
            return .clue(digit)
        }
    }

    public subscript(_ position: Position) -> Cell {
        precondition(contains(position), "Position is outside the board size.")
        return cells[uncheckedIndex(for: position)]
    }

    public func cell(at position: Position) throws -> Cell {
        cells[try index(for: position)]
    }

    var constraintGroups: [[Position]] {
        (0..<boardSize.size).map(row)
            + (0..<boardSize.size).map(column)
            + (0..<boardSize.size).map(block)
    }

    public mutating func setEntry(_ digit: Digit?, at position: Position) throws {
        let index = try index(for: position)
        let cell = cells[index]

        guard !cell.isClue else {
            throw SudokuDomainError.cannotChangeClue(position)
        }

        if let digit {
            try Self.validate(digit, boardSize: boardSize)
        }

        cells[index] = digit.map(Cell.entry) ?? .empty
    }

    private var cellCount: Int {
        Self.cellCount(for: boardSize)
    }

    private var maximumDigit: Int {
        boardSize.size
    }

    private func contains(_ position: Position) -> Bool {
        (0..<boardSize.size).contains(position.row)
            && (0..<boardSize.size).contains(position.column)
    }

    private func contains(_ digit: Digit) -> Bool {
        (1...maximumDigit).contains(digit.value)
    }

    private func index(for position: Position) throws -> Int {
        guard contains(position) else {
            throw SudokuDomainError.invalidPosition(position)
        }

        return uncheckedIndex(for: position)
    }

    private func uncheckedIndex(for position: Position) -> Int {
        position.row * boardSize.size + position.column
    }

    private func row(_ row: Int) -> [Position] {
        (0..<boardSize.size).map { column in
            Position(row: row, column: column)
        }
    }

    private func column(_ column: Int) -> [Position] {
        (0..<boardSize.size).map { row in
            Position(row: row, column: column)
        }
    }

    private func block(_ block: Int) -> [Position] {
        let firstRow = (block / boardSize.blockSide) * boardSize.blockSide
        let firstColumn = (block % boardSize.blockSide) * boardSize.blockSide

        return (firstRow..<(firstRow + boardSize.blockSide)).flatMap { row in
            (firstColumn..<(firstColumn + boardSize.blockSide)).map { column in
                Position(row: row, column: column)
            }
        }
    }

    private static func cellCount(for boardSize: BoardSize) -> Int {
        boardSize.size * boardSize.size
    }

    private static func validate(_ boardSize: BoardSize) throws {
        guard boardSize.size > 0,
            boardSize.blockSide > 0,
            boardSize.blockSide * boardSize.blockSide == boardSize.size
        else {
            throw SudokuDomainError.invalidBoardSize(
                size: boardSize.size,
                blockSide: boardSize.blockSide
            )
        }
    }

    private static func validate(_ cells: [Cell], boardSize: BoardSize) throws {
        for cell in cells {
            guard let digit = cell.digit else { continue }
            try validate(digit, boardSize: boardSize)
        }
    }

    private static func validate(_ digit: Digit, boardSize: BoardSize) throws {
        guard (1...boardSize.size).contains(digit.value) else {
            throw SudokuDomainError.invalidDigit(value: digit.value, maximum: boardSize.size)
        }
    }
}
