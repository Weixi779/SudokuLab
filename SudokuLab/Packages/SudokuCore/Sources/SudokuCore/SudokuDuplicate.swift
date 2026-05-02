public struct SudokuDuplicate: Equatable, Hashable, Sendable {
    public let digit: SudokuDigit
    public let house: SudokuHouse
    public let squares: [SudokuSquare]

    public init(digit: SudokuDigit, house: SudokuHouse, squares: [SudokuSquare]) {
        self.digit = digit
        self.house = house
        self.squares = squares
    }
}
