import SudokuCore
import Testing

@Suite
struct SudokuCoreTests {
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

    @Test func boardSizeStoresStandardConfiguration() {
        let boardSize = BoardSize.standard

        #expect(boardSize.size == 9)
        #expect(boardSize.blockSide == 3)
    }

    @Test func boardSizeStoresCustomConfiguration() {
        let boardSize = BoardSize(size: 4, blockSide: 2)

        #expect(boardSize.size == 4)
        #expect(boardSize.blockSide == 2)
    }
}
