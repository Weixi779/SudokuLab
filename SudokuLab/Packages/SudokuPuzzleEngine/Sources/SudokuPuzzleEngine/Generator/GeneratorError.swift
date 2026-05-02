public enum GeneratorError: Error, Equatable, Sendable {
    case invalidTargetClueCount(Int)
    case unableToGenerateSolution
    case unableToReachTargetClueCount(target: Int, actual: Int)
}
