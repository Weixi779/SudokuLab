public struct Digit: Equatable, Hashable, Comparable, Sendable {
    public let value: Int

    public init(_ value: Int) {
        self.value = value
    }

    public static func < (lhs: Digit, rhs: Digit) -> Bool {
        lhs.value < rhs.value
    }
}
