# 0005: Extract SudokuBoardEngine Package

Date: 2026-05-02

## Status

Accepted, amended by [0006](0006-refine-sudoku-package-boundaries.md)

2026-05-03 amendment: `SudokuBoardEngine` now depends on `SudokuCore` for
shared primitive values and validation issue coordinates. The old `PuzzleUnit`
API is removed.

2026-05-06 amendment: superseded by [0006](0006-refine-sudoku-package-boundaries.md).
`SudokuBoardEngine` now depends on `SudokuDomain` for board solver/generator
contracts. `PuzzleGrid` and the validator family are implementation details
instead of the package's app-facing API.

## Context

Sudoku solving, numeric validation, solution counting, uniqueness checks,
generation, and future difficulty rating are pure puzzle-computation concerns.
They should stay independent from SwiftUI, SwiftData, FactoryKit, and the
app-facing semantic model now isolated in `SudokuDomain`.

`SudokuCore` expresses shared primitive values such as digits and positions.
After the 2026-05-06 amendment, the board engine uses `SudokuDomain.Board`
contracts publicly while keeping a numeric `PuzzleGrid` representation and
standard 9x9 topology internally.

## Decision

Create a local Swift package named `SudokuBoardEngine` under
`SudokuLab/Packages/SudokuBoardEngine`.

The package now depends on `SudokuDomain` and implements its board solver and
generator contracts. App-facing code should use `Board`, `BoardSolver`, and
`BoardGenerator`; engine numeric grid types are reserved for internal
implementation and tests.

The package currently supports only standard 9x9 Sudoku. Public API terms use:

- `MRVBitmaskBoardSolver` for solving, solution counting, and uniqueness checks.
- `RandomizedBoardGenerator` for seeded or system-random board generation. It
  stores a copyable `BoardGenerationConfiguration` and generates through a
  mutating `generate()` effect.

`0` represents an empty cell. Digits `1...9` represent filled cells. Existing
duplicate digits are accepted by the internal numeric grid as structurally valid
input, then treated as an unsolvable board by the solver.

Validators still use throwing APIs internally for engine tests and generator
checks, but they are no longer the public app-facing validation contract.

The initial solver uses deterministic bitmask backtracking with a minimum
remaining values cell choice. DLX, exact cover, or other algorithms can replace
or supplement this internally later. Algorithm names are not part of the public
API.

The initial generator creates a randomized complete solution, then removes clues
while preserving uniqueness. The default `.locallyMinimal` goal keeps every
accepted removal and stops after all cells have been considered; this is local
minimality for the generated removal order, not a proof of globally minimum clue
count.

Difficulty rating, candidate notes, and human solving technique analysis remain
future work.

## Consequences

- Package tests use ordinary `import SudokuBoardEngine` for public solver and
  generator behavior, and `@testable import` for internal grid/validator checks.
- The app can link `SudokuBoardEngine` as an implementation of
  `SudokuDomain` board contracts.
- Benchmarks can be added later to compare internal solver/generator strategies
  without changing public callers.
