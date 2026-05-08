struct ValidationFailure: Error, Equatable, Sendable {
    let issues: [ValidationIssue]

    init(issues: [ValidationIssue]) {
        self.issues = issues
    }
}

extension ValidationFailure {
    static func throwIfNeeded(_ issues: [ValidationIssue]) throws {
        guard !issues.isEmpty else { return }

        throw ValidationFailure(issues: issues)
    }
}
