import SudokuCore

public enum SudokuCell: Equatable, Hashable, Sendable {
    case empty
    case clue(Digit)
    case entry(Digit)

    public var digit: Digit? {
        switch self {
        case .empty:
            nil
        case .clue(let digit), .entry(let digit):
            digit
        }
    }

    public var isClue: Bool {
        if case .clue = self {
            true
        } else {
            false
        }
    }
}
