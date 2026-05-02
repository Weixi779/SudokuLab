public enum PuzzleUnitError: Error, Equatable, Sendable {
    case invalidIndex(kind: PuzzleUnit.Kind, index: Int)
}

public struct PuzzleUnit: Equatable, Hashable, Sendable {
    public enum Kind: Equatable, Hashable, Sendable {
        case row
        case column
        case block
    }

    public let kind: Kind
    public let index: Int

    public init(kind: Kind, index: Int) throws {
        guard (0..<PuzzleGrid.size).contains(index) else {
            throw PuzzleUnitError.invalidIndex(kind: kind, index: index)
        }

        self.kind = kind
        self.index = index
    }

    public static func row(_ index: Int) throws -> PuzzleUnit {
        try PuzzleUnit(kind: .row, index: index)
    }

    public static func column(_ index: Int) throws -> PuzzleUnit {
        try PuzzleUnit(kind: .column, index: index)
    }

    public static func block(_ index: Int) throws -> PuzzleUnit {
        try PuzzleUnit(kind: .block, index: index)
    }

    init(uncheckedKind kind: Kind, index: Int) {
        self.kind = kind
        self.index = index
    }
}
