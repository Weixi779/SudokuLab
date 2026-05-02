public struct GeneratorOptions: Equatable, Sendable {
    public var goal: GeneratorGoal

    public init(goal: GeneratorGoal = .locallyMinimal) {
        self.goal = goal
    }
}
