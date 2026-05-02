public protocol Validator: Sendable {
    func validate(_ grid: PuzzleGrid) throws
}
