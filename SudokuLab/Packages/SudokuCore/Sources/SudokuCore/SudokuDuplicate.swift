public struct SudokuDuplicate: Equatable, Hashable, Sendable {
    public let digit: Digit
    public let house: SudokuHouse
    public let squares: [SudokuSquare]

    public init(digit: Digit, house: SudokuHouse, squares: [SudokuSquare]) {
        self.digit = digit
        self.house = house
        self.squares = squares
    }
}
