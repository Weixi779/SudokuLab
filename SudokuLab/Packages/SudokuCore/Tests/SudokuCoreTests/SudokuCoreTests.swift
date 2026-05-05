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

    @Test func positionStoresCoordinatesAndSorts() {
        let topLeft = Position(row: 0, column: 0)
        let center = Position(row: 4, column: 4)
        let bottomRight = Position(row: 8, column: 8)

        #expect(topLeft.row == 0)
        #expect(topLeft.column == 0)
        #expect(center.row == 4)
        #expect(center.column == 4)
        #expect([bottomRight, topLeft, center].sorted() == [topLeft, center, bottomRight])
    }

    @Test func houseAcceptsValidBoundsAndHasStableOrder() throws {
        let row = try SudokuHouse.row(8)
        let column = try SudokuHouse.column(8)
        let block = try SudokuHouse.block(8)

        #expect(row.positions == positions((0..<9).map { (8, $0) }))
        #expect(column.positions == positions((0..<9).map { ($0, 8) }))
        #expect(
            block.positions
                == positions([
                    (6, 6), (6, 7), (6, 8),
                    (7, 6), (7, 7), (7, 8),
                    (8, 6), (8, 7), (8, 8),
                ])
        )
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

    private func positions(_ values: [(Int, Int)]) -> [Position] {
        values.map { Position(row: $0.0, column: $0.1) }
    }
}
