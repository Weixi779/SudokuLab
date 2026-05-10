import SudokuCore

public struct Board: Equatable, Sendable {
    public let size: BoardSize
    private var cells: [Cell]

    public init() {
        size = .standard
        cells = Array(repeating: .empty, count: Self.cellCount(for: size))
    }

    public init(cells: [Cell]) throws {
        let boardSize = BoardSize.standard

        guard cells.count == Self.cellCount(for: boardSize) else {
            throw SudokuDomainError.invalidCellCount(
                value: cells.count,
                expected: Self.cellCount(for: boardSize)
            )
        }

        try Self.validate(cells, boardSize: boardSize)

        size = boardSize
        self.cells = cells
    }

    public init(clues: [Int?]) throws {
        let boardSize = BoardSize.standard

        guard clues.count == Self.cellCount(for: boardSize) else {
            throw SudokuDomainError.invalidCellCount(
                value: clues.count,
                expected: Self.cellCount(for: boardSize)
            )
        }

        size = boardSize
        cells = try clues.map { value in
            guard let value else { return .empty }
            let digit = Digit(value)
            try Self.validate(digit, boardSize: boardSize)
            return .clue(digit)
        }
    }

    public subscript(_ position: Position) -> Cell {
        precondition(contains(position), "Position is outside the board.")
        return cells[uncheckedIndex(for: position)]
    }

    public func cell(at position: Position) throws -> Cell {
        cells[try index(for: position)]
    }

    public var cellCount: Int {
        Self.cellCount(for: size)
    }

    public var positions: [Position] {
        (0..<size.size).flatMap { row in
            (0..<size.size).map { column in
                Position(row: row, column: column)
            }
        }
    }

    public var rows: [[Position]] {
        (0..<size.size).map { self[row: $0] }
    }

    public var columns: [[Position]] {
        (0..<size.size).map { self[column: $0] }
    }

    public var blocks: [[Position]] {
        (0..<size.size).map { self[block: $0] }
    }

    public subscript(row row: Int) -> [Position] {
        precondition((0..<size.size).contains(row), "Row is outside the board.")

        return (0..<size.size).map { column in
            Position(row: row, column: column)
        }
    }

    public subscript(column column: Int) -> [Position] {
        precondition((0..<size.size).contains(column), "Column is outside the board.")

        return (0..<size.size).map { row in
            Position(row: row, column: column)
        }
    }

    public subscript(block block: Int) -> [Position] {
        precondition((0..<size.size).contains(block), "Block is outside the board.")

        let firstRow = (block / size.blockSide) * size.blockSide
        let firstColumn = (block % size.blockSide) * size.blockSide

        return (firstRow..<(firstRow + size.blockSide)).flatMap { row in
            (firstColumn..<(firstColumn + size.blockSide)).map { column in
                Position(row: row, column: column)
            }
        }
    }

    public mutating func setEntry(_ digit: Digit?, at position: Position) throws {
        let index = try index(for: position)
        let cell = cells[index]

        guard !cell.isClue else {
            throw SudokuDomainError.cannotChangeClue(position)
        }

        if let digit {
            try Self.validate(digit, boardSize: size)
        }

        cells[index] = digit.map(Cell.entry) ?? .empty
    }

    private var maximumDigit: Int {
        size.size
    }

    public func contains(_ position: Position) -> Bool {
        (0..<size.size).contains(position.row)
            && (0..<size.size).contains(position.column)
    }

    public func contains(_ digit: Digit) -> Bool {
        (1...maximumDigit).contains(digit.value)
    }

    private func index(for position: Position) throws -> Int {
        guard contains(position) else {
            throw SudokuDomainError.invalidPosition(position)
        }

        return uncheckedIndex(for: position)
    }

    private func uncheckedIndex(for position: Position) -> Int {
        position.row * size.size + position.column
    }

    private static func cellCount(for boardSize: BoardSize) -> Int {
        boardSize.size * boardSize.size
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
