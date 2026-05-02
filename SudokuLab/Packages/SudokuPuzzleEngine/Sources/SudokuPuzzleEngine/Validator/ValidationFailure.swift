public struct ValidationFailure: Error, Equatable, Sendable {
    public let issues: [ValidationIssue]

    public init(issues: [ValidationIssue]) {
        self.issues = issues
    }
}

extension ValidationFailure {
    public static func throwIfNeeded(_ issues: [ValidationIssue]) throws {
        guard !issues.isEmpty else { return }

        throw ValidationFailure(issues: issues)
    }
}
