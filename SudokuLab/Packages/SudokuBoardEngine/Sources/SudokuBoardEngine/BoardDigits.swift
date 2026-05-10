import SudokuCore
import SudokuDomain

struct BoardDigits: Equatable, Hashable, Sendable {
    static let topology = BoardTopology()
    static let size = topology.size.sideLength
    static let cellCount = topology.size.cellCount

    private let values: [Int]

    var digits: [Int] {
        values
    }

    init(board: Board) {
        values = board.positions.map { position in
            board[position].digit?.value ?? 0
        }
    }

    init(uncheckedDigits digits: [Int]) {
        values = digits
    }

    func clueBoard() throws -> Board {
        try Board(
            clues: values.map { digit in
                digit == 0 ? nil : digit
            }
        )
    }

    func entryBoard() throws -> Board {
        try Board(
            cells: values.map { digit in
                digit == 0 ? .empty : .entry(Digit(digit))
            }
        )
    }
}
