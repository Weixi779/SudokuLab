public enum SudokuDuplicateScanner {
    public static func duplicates(
        digitAt digitForSquare: (SudokuSquare) throws -> Digit?
    ) rethrows -> [SudokuDuplicate] {
        try SudokuHouse.all.flatMap { house in
            try duplicates(in: house, digitAt: digitForSquare)
        }
    }

    public static func duplicates(
        in house: SudokuHouse,
        digitAt digitForSquare: (SudokuSquare) throws -> Digit?
    ) rethrows -> [SudokuDuplicate] {
        var squaresByDigit: [Digit: [SudokuSquare]] = [:]

        for square in house.squares {
            guard let digit = try digitForSquare(square) else { continue }
            squaresByDigit[digit, default: []].append(square)
        }

        return squaresByDigit.keys.sorted().compactMap { digit in
            let squares = squaresByDigit[digit, default: []].sorted()
            guard squares.count > 1 else { return nil }
            return SudokuDuplicate(digit: digit, house: house, squares: squares)
        }
    }
}
