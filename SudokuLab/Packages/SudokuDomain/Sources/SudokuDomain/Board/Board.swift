import SudokuCore

public struct Board: Sendable {
    public let size: BoardSize
    private var cells: [Cell]
    private let topology: Topology

    // MARK: - Initialization

    public init() {
        let boardSize = BoardSize.standard

        self.init(size: boardSize, cells: Array(repeating: .empty, count: boardSize.cellCount))
    }

    public init(cells: [Cell]) throws {
        let boardSize = BoardSize.standard

        guard cells.count == boardSize.cellCount else {
            throw BoardError.invalidCellCount(
                value: cells.count,
                expected: boardSize.cellCount
            )
        }

        try Self.validate(cells, boardSize: boardSize)

        self.init(size: boardSize, cells: cells)
    }

    public init(clues: [Int?]) throws {
        let boardSize = BoardSize.standard

        guard clues.count == boardSize.cellCount else {
            throw BoardError.invalidCellCount(
                value: clues.count,
                expected: boardSize.cellCount
            )
        }

        let cells: [Cell] = try clues.map { value in
            guard let value else { return .empty }
            let digit = Digit(value)
            try Self.validate(digit, boardSize: boardSize)
            return .clue(digit)
        }

        self.init(size: boardSize, cells: cells)
    }

    fileprivate init(size: BoardSize, cells: [Cell]) {
        self.size = size
        topology = Topology(size: size)
        self.cells = cells
    }

    // MARK: - Dimensions

    public var cellCount: Int {
        size.cellCount
    }
}

extension Board: Equatable {
    public static func == (lhs: Board, rhs: Board) -> Bool {
        lhs.size == rhs.size && lhs.cells == rhs.cells
    }
}

// MARK: - Cell Access

extension Board {
    public subscript(_ position: Position) -> Cell {
        precondition(contains(position), "Position is outside the board.")
        return cells[uncheckedIndex(for: position)]
    }

    public func cell(at position: Position) throws -> Cell {
        cells[try index(for: position)]
    }
}

// MARK: - Topology

extension Board {
    public var positions: [Position] {
        topology.positions
    }

    public subscript(row index: Int) -> [Position] {
        precondition(topology.rows.indices.contains(index), "Row is outside the board.")
        return topology.rows[index]
    }

    public subscript(column index: Int) -> [Position] {
        precondition(topology.columns.indices.contains(index), "Column is outside the board.")
        return topology.columns[index]
    }

    public subscript(block index: Int) -> [Position] {
        precondition(topology.blocks.indices.contains(index), "Block is outside the board.")
        return topology.blocks[index]
    }
}

// MARK: - Mutation

extension Board {
    public mutating func setEntry(_ digit: Digit?, at position: Position) throws {
        let index = try index(for: position)
        let cell = cells[index]

        guard !cell.isClue else {
            throw BoardError.cannotChangeClue(position)
        }

        if let digit {
            try Self.validate(digit, boardSize: size)
        }

        cells[index] = digit.map(Cell.entry) ?? .empty
    }
}

// MARK: - Validation

extension Board {
    public func contains(_ position: Position) -> Bool {
        topology.contains(position)
    }

    public func contains(_ digit: Digit) -> Bool {
        size.digitValues.contains(digit.value)
    }
}

// MARK: - Private Validation

extension Board {
    fileprivate static func validate(_ cells: [Cell], boardSize: BoardSize) throws {
        for cell in cells {
            guard let digit = cell.digit else { continue }
            try validate(digit, boardSize: boardSize)
        }
    }

    fileprivate static func validate(_ digit: Digit, boardSize: BoardSize) throws {
        guard boardSize.digitValues.contains(digit.value) else {
            throw BoardError.invalidDigit(value: digit.value, maximum: boardSize.sideLength)
        }
    }
}

// MARK: - Private Indexing

extension Board {
    fileprivate func index(for position: Position) throws -> Int {
        guard contains(position) else {
            throw BoardError.invalidPosition(position)
        }

        return uncheckedIndex(for: position)
    }

    fileprivate func uncheckedIndex(for position: Position) -> Int {
        position.row * size.sideLength + position.column
    }
}

// MARK: - Topology Model

private struct Topology: Sendable {
    let positions: [Position]
    let rows: [[Position]]
    let columns: [[Position]]
    let blocks: [[Position]]

    private let sideLength: Int

    init(size: BoardSize) {
        let indices = size.positionIndices
        let rows = Self.makeRows(indices: indices)

        sideLength = size.sideLength
        self.rows = rows
        positions = rows.flatMap { $0 }
        columns = Self.makeColumns(indices: indices)
        blocks = Self.makeBlocks(indices: indices, blockSide: size.blockSide)
    }

    private func lowerThanLength(_ index: Int) -> Bool {
        index >= 0 && index < sideLength
    }

    func contains(_ position: Position) -> Bool {
        lowerThanLength(position.row) && lowerThanLength(position.column)
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
