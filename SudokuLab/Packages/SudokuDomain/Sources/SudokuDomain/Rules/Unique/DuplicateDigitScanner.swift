import SudokuCore

internal enum DuplicateDigitScanner {
    static func violations(in positions: [Position], on board: Board) -> [Violation] {
        let digitValues = board.size.digitValues
        var positionsByDigit = Array(repeating: [Position](), count: digitValues.upperBound + 1)

        for position in positions where board.contains(position) {
            guard let digit = board[position].digit else { continue }
            positionsByDigit[digit.value].append(position)
        }

        return digitValues.compactMap { digitValue in
            let positions = positionsByDigit[digitValue]
            guard positions.count > 1 else { return nil }
            return .duplicateDigit(Digit(digitValue), positions: positions)
        }
    }
}
