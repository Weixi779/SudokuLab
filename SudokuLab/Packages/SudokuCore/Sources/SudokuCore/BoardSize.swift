public enum BoardSize: Equatable, Hashable, Sendable {
    case standard

    public var sideLength: Int {
        switch self {
        case .standard:
            9
        }
    }

    public var cellCount: Int {
        sideLength * sideLength
    }

    public var positionIndices: Range<Int> {
        0..<sideLength
    }

    public var digitValues: ClosedRange<Int> {
        1...sideLength
    }

    public var blockSide: Int {
        switch self {
        case .standard:
            3
        }
    }
}
