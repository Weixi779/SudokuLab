public protocol BoardGenerator: Sendable {
    var configuration: BoardGenerationConfiguration { get set }

    mutating func generate() throws -> GeneratedBoard
}

public struct GeneratedBoard: Equatable, Sendable {
    public let puzzle: Board
    public let solution: Board

    public var clueCount: Int {
        puzzle.positions.reduce(into: 0) { count, position in
            if puzzle[position].isClue {
                count += 1
            }
        }
    }

    public init(puzzle: Board, solution: Board) {
        self.puzzle = puzzle
        self.solution = solution
    }
}

public struct BoardGenerationConfiguration: Equatable, Sendable {
    public var goal: BoardGenerationGoal

    public init(goal: BoardGenerationGoal = .locallyMinimal) {
        self.goal = goal
    }
}

public enum BoardGenerationGoal: Equatable, Sendable {
    case locallyMinimal
    case targetClueCount(Int)
}

public enum BoardGenerationError: Error, Equatable, Sendable {
    case invalidTargetClueCount(Int)
    case unableToGenerateSolution
    case unableToReachTargetClueCount(target: Int, actual: Int)
}
