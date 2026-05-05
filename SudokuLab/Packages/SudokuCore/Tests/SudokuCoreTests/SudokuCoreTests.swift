import SudokuCore
import Testing

@Suite
struct SudokuCoreTests {
    @Test func layoutHasStandardNineByNineTopology() {
        #expect(SudokuLayout.size == 9)
        #expect(SudokuLayout.cellCount == 81)
        #expect(SudokuLayout.blockSide == 3)
        #expect(SudokuLayout.rowIndex(forSquareIndex: 40) == 4)
        #expect(SudokuLayout.columnIndex(forSquareIndex: 40) == 4)
        #expect(SudokuLayout.blockIndex(forSquareIndex: 40) == 4)
        #expect(SudokuLayout.blockIndex(rowIndex: 8, columnIndex: 8) == 8)
        #expect(SudokuLayout.squareIndex(rowIndex: 8, columnIndex: 8) == 80)
    }

    @Test func digitStoresValueAndSorts() {
        let one = Digit(1)
        let nine = Digit(9)

        #expect(one.value == 1)
        #expect(nine.value == 9)
        #expect([nine, one].sorted() == [one, nine])
    }

    @Test func squareAcceptsValidBoundsAndDerivesPosition() throws {
        let first = try SudokuSquare(0)
        let last = try SudokuSquare(80)
        let center = try SudokuSquare(rowIndex: 4, columnIndex: 4)

        #expect(first.rawValue == 0)
        #expect(first.rowIndex == 0)
        #expect(first.columnIndex == 0)
        #expect(first.blockIndex == 0)
        #expect(last.rawValue == 80)
        #expect(last.rowIndex == 8)
        #expect(last.columnIndex == 8)
        #expect(last.blockIndex == 8)
        #expect(center.rawValue == 40)
        #expect(center.blockIndex == 4)
        #expect(SudokuSquare.all.count == SudokuLayout.cellCount)
    }

    @Test func squareRejectsInvalidValues() {
        #expect(throws: SudokuError.invalidSquareIndex(-1)) {
            try SudokuSquare(-1)
        }
        #expect(throws: SudokuError.invalidSquareIndex(81)) {
            try SudokuSquare(81)
        }
        #expect(throws: SudokuError.invalidSquare(rowIndex: -1, columnIndex: 0)) {
            try SudokuSquare(rowIndex: -1, columnIndex: 0)
        }
        #expect(throws: SudokuError.invalidSquare(rowIndex: 0, columnIndex: 9)) {
            try SudokuSquare(rowIndex: 0, columnIndex: 9)
        }
    }

    @Test func houseAcceptsValidBoundsAndHasStableOrder() throws {
        let row = try SudokuHouse.row(8)
        let column = try SudokuHouse.column(8)
        let block = try SudokuHouse.block(8)

        #expect(row.squares.map(\.rawValue) == Array(72...80))
        #expect(column.squares.map(\.rawValue) == stride(from: 8, through: 80, by: 9).map { $0 })
        #expect(block.squares.map(\.rawValue) == [60, 61, 62, 69, 70, 71, 78, 79, 80])
        #expect(SudokuHouse.all.count == 27)
        #expect(SudokuHouse.all.prefix(9).allSatisfy { $0.kind == .row })
        #expect(SudokuHouse.all.dropFirst(9).prefix(9).allSatisfy { $0.kind == .column })
        #expect(SudokuHouse.all.dropFirst(18).allSatisfy { $0.kind == .block })
    }

    @Test func houseRejectsInvalidIndex() {
        #expect(throws: SudokuError.invalidHouseIndex(kind: .row, index: -1)) {
            try SudokuHouse.row(-1)
        }
        #expect(throws: SudokuError.invalidHouseIndex(kind: .block, index: 9)) {
            try SudokuHouse.block(9)
        }
    }

    @Test func duplicateScannerFindsDuplicatesInStableHouseOrder() throws {
        let five = Digit(5)
        let values: [Int: Digit] = [
            0: five,
            3: five,
            10: five,
        ]

        let duplicates = SudokuDuplicateScanner.duplicates { square in
            values[square.rawValue]
        }

        #expect(
            duplicates == [
                SudokuDuplicate(
                    digit: five,
                    house: try SudokuHouse.row(0),
                    squares: [
                        try SudokuSquare(rowIndex: 0, columnIndex: 0),
                        try SudokuSquare(rowIndex: 0, columnIndex: 3),
                    ]
                ),
                SudokuDuplicate(
                    digit: five,
                    house: try SudokuHouse.block(0),
                    squares: [
                        try SudokuSquare(rowIndex: 0, columnIndex: 0),
                        try SudokuSquare(rowIndex: 1, columnIndex: 1),
                    ]
                ),
            ]
        )
    }
}
