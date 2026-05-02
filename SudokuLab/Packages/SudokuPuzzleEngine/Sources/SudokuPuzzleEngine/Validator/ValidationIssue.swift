public enum ValidationIssue: Error, Equatable, Hashable, Sendable {
    case duplicateDigit(digit: Int, unit: PuzzleUnit, cellIndices: [Int])
    case emptyCells(cellIndices: [Int])
    case noSolution
    case multipleSolutions
}
