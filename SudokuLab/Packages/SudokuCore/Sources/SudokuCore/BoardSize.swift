public enum BoardSize: Equatable, Hashable, Sendable {
    case standard

    public var size: Int {
        switch self {
        case .standard:
            9
        }
    }

    public var blockSide: Int {
        switch self {
        case .standard:
            3
        }
    }
}
