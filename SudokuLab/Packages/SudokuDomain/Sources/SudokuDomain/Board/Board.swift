import SudokuCore

public struct Board: Sendable {
    public let size: BoardSize
    public let topology: BoardTopology
    private var cells: [Cell]

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
        topology = BoardTopology(size: size)
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
        return cells[topology.uncheckedIndex(for: position)]
    }

    public func cell(at position: Position) throws -> Cell {
        cells[try topology.index(for: position)]
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
        let index = try topology.index(for: position)
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
