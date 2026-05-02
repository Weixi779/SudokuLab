public struct GeneratedPuzzle: Equatable, Sendable {
    public let puzzle: PuzzleGrid
    public let solution: PuzzleGrid

    public var clueCount: Int {
        puzzle.cells.reduce(into: 0) { count, digit in
            if digit != 0 {
                count += 1
            }
        }
    }

    public init(puzzle: PuzzleGrid, solution: PuzzleGrid) {
        self.puzzle = puzzle
        self.solution = solution
    }
}
