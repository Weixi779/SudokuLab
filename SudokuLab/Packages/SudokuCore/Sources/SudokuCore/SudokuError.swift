public enum SudokuError: Error, Equatable, Sendable {
    case invalidHouseIndex(kind: SudokuHouse.Kind, index: Int)
}
