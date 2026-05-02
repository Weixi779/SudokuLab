import SudokuCore

struct SolutionBuilder {
    private static let allCandidatesMask = (1 << SudokuLayout.size) - 1

    var cells = Array(repeating: 0, count: SudokuLayout.cellCount)

    private var rowMasks = Array(repeating: 0, count: SudokuLayout.size)
    private var columnMasks = Array(repeating: 0, count: SudokuLayout.size)
    private var blockMasks = Array(repeating: 0, count: SudokuLayout.size)

    mutating func fill<Random: RandomNumberGenerator>(using randomNumberGenerator: inout Random)
        -> Bool
    {
        guard let choice = nextChoice() else { return true }
        var digits = Self.digits(in: choice.candidates)

        digits.shuffle(using: &randomNumberGenerator)

        for digit in digits {
            let bit = Self.bit(for: digit)

            place(digit, at: choice.index, bit: bit)
            if fill(using: &randomNumberGenerator) {
                return true
            }
            remove(at: choice.index, bit: bit)
        }

        return false
    }

    private func nextChoice() -> (index: Int, candidates: Int)? {
        var bestIndex: Int?
        var bestCandidates = 0
        var bestCount = Int.max

        for index in cells.indices where cells[index] == 0 {
            let candidates = candidatesMask(at: index)
            let count = candidates.nonzeroBitCount

            if count == 0 {
                return (index, 0)
            }

            if count < bestCount {
                bestIndex = index
                bestCandidates = candidates
                bestCount = count

                if count == 1 {
                    break
                }
            }
        }

        guard let bestIndex else { return nil }
        return (bestIndex, bestCandidates)
    }

    private func candidatesMask(at index: Int) -> Int {
        let row = SudokuLayout.rowIndex(forSquareIndex: index)
        let column = SudokuLayout.columnIndex(forSquareIndex: index)
        let block = SudokuLayout.blockIndex(rowIndex: row, columnIndex: column)

        return Self.allCandidatesMask & ~(rowMasks[row] | columnMasks[column] | blockMasks[block])
    }

    private mutating func place(_ digit: Int, at index: Int, bit: Int) {
        let row = SudokuLayout.rowIndex(forSquareIndex: index)
        let column = SudokuLayout.columnIndex(forSquareIndex: index)
        let block = SudokuLayout.blockIndex(rowIndex: row, columnIndex: column)

        cells[index] = digit
        rowMasks[row] |= bit
        columnMasks[column] |= bit
        blockMasks[block] |= bit
    }

    private mutating func remove(at index: Int, bit: Int) {
        let row = SudokuLayout.rowIndex(forSquareIndex: index)
        let column = SudokuLayout.columnIndex(forSquareIndex: index)
        let block = SudokuLayout.blockIndex(rowIndex: row, columnIndex: column)

        cells[index] = 0
        rowMasks[row] &= ~bit
        columnMasks[column] &= ~bit
        blockMasks[block] &= ~bit
    }

    private static func digits(in mask: Int) -> [Int] {
        var digits: [Int] = []
        var candidates = mask

        digits.reserveCapacity(SudokuLayout.size)

        while candidates != 0 {
            let bit = candidates & -candidates
            digits.append(bit.trailingZeroBitCount + 1)
            candidates &= candidates - 1
        }

        return digits
    }

    private static func bit(for digit: Int) -> Int {
        1 << (digit - 1)
    }
}
