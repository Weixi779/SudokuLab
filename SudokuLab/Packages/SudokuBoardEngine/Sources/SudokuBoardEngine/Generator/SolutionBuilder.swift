struct SolutionBuilder {
    private static let allCandidatesMask = (1 << BoardDigits.size) - 1

    var digits = Array(repeating: 0, count: BoardDigits.cellCount)

    private var rowMasks = Array(repeating: 0, count: BoardDigits.size)
    private var columnMasks = Array(repeating: 0, count: BoardDigits.size)
    private var blockMasks = Array(repeating: 0, count: BoardDigits.size)

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

        for index in digits.indices where digits[index] == 0 {
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
        let row = BoardDigits.topology.row(forIndex: index)
        let column = BoardDigits.topology.column(forIndex: index)
        let block = BoardDigits.topology.block(row: row, column: column)

        return Self.allCandidatesMask & ~(rowMasks[row] | columnMasks[column] | blockMasks[block])
    }

    private mutating func place(_ digit: Int, at index: Int, bit: Int) {
        let row = BoardDigits.topology.row(forIndex: index)
        let column = BoardDigits.topology.column(forIndex: index)
        let block = BoardDigits.topology.block(row: row, column: column)

        digits[index] = digit
        rowMasks[row] |= bit
        columnMasks[column] |= bit
        blockMasks[block] |= bit
    }

    private mutating func remove(at index: Int, bit: Int) {
        let row = BoardDigits.topology.row(forIndex: index)
        let column = BoardDigits.topology.column(forIndex: index)
        let block = BoardDigits.topology.block(row: row, column: column)

        digits[index] = 0
        rowMasks[row] &= ~bit
        columnMasks[column] &= ~bit
        blockMasks[block] &= ~bit
    }

    private static func digits(in mask: Int) -> [Int] {
        var digits: [Int] = []
        var candidates = mask

        digits.reserveCapacity(BoardDigits.size)

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
