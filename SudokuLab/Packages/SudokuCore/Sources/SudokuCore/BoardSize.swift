public struct BoardSize: Equatable, Hashable, Sendable {
    public static let standard = BoardSize(size: 9, blockSide: 3)

    public let size: Int
    public let blockSide: Int

    public init(size: Int, blockSide: Int) {
        self.size = size
        self.blockSide = blockSide
    }
}
