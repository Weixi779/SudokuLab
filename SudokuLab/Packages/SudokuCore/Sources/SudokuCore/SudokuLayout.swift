public enum SudokuLayout {
    public static let size = 9
    public static let cellCount = size * size
    public static let blockSide = 3

    public static func rowIndex(forSquareIndex squareIndex: Int) -> Int {
        squareIndex / size
    }

    public static func columnIndex(forSquareIndex squareIndex: Int) -> Int {
        squareIndex % size
    }

    public static func blockIndex(forSquareIndex squareIndex: Int) -> Int {
        blockIndex(
            rowIndex: rowIndex(forSquareIndex: squareIndex),
            columnIndex: columnIndex(forSquareIndex: squareIndex)
        )
    }

    public static func blockIndex(rowIndex: Int, columnIndex: Int) -> Int {
        (rowIndex / blockSide) * blockSide + columnIndex / blockSide
    }

    public static func squareIndex(rowIndex: Int, columnIndex: Int) -> Int {
        rowIndex * size + columnIndex
    }
}
