import SudokuCore

public protocol Rule: Sendable {
    func validate(_ board: Board) -> [Violation]
    func candidates(at position: Position, on board: Board) -> Set<Digit>?
}
