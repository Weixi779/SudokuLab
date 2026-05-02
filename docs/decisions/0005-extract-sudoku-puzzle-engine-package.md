# 0005: Extract SudokuPuzzleEngine Package

Date: 2026-05-02

## Status

Accepted

## Context

Sudoku solving, numeric validation, solution counting, uniqueness checks,
generation, and future difficulty rating are pure puzzle-computation concerns.
They should stay independent from SwiftUI, SwiftData, FactoryKit, and the
app-facing semantic model in `SudokuCore`.

`SudokuCore` expresses domain meaning such as clues, entries, houses, and rule
violations. The puzzle engine needs a smaller numeric contract that can be
optimized internally without changing app/domain API names.

## Decision

Create a local Swift package named `SudokuPuzzleEngine` under
`SudokuLab/Packages/SudokuPuzzleEngine`.

The package is independent from `SudokuCore`. Neither package imports the other.
App features or adapters are responsible for converting between domain grids and
engine grids when both are needed.

The package currently supports only standard 9x9 Sudoku. Public API terms use:

- `PuzzleGrid` for the fixed 81-cell numeric puzzle grid.
- `PuzzleGridError` for invalid cell count or digit input.
- `Solver` for solving, solution counting, and uniqueness checks.
- `Validator` for composable validation capabilities.
- `PuzzleUnit` and `PuzzleUnitError` for checked row, column, and block units.
- `RulesValidator` for row, column, and block duplicate checks.
- `SolvedGridValidator` for filled, rule-valid solution grids.
- `UniqueSolutionValidator` for puzzle uniqueness checks.
- `CompositeValidator` for aggregating failures from several validators.
- `ShortCircuitCompositeValidator` for stopping at the first failed validator.
- `ValidationIssue` and `ValidationFailure` for thrown validation failures.

`0` represents an empty cell. Digits `1...9` represent filled cells. Existing
duplicate digits are accepted by `PuzzleGrid` as structurally valid input, then
treated as an unsolvable puzzle by `Solver`.

Validators use throwing APIs. `ValidationIssue` conforms to `Error`, and
validators throw `ValidationFailure` so one validation pass can report multiple
issues. Custom validators should throw `ValidationFailure`; the public
`ValidationFailure.throwIfNeeded` helper exists for that purpose.

The initial solver uses deterministic bitmask backtracking with a minimum
remaining values cell choice. DLX, exact cover, or other algorithms can replace
or supplement this internally later. Algorithm names are not part of the public
API.

Generation, difficulty rating, candidate notes, and human solving technique
analysis remain future work.

## Consequences

- Package tests use ordinary `import SudokuPuzzleEngine` to verify the public
  API boundary.
- The app can link `SudokuPuzzleEngine` without making `SudokuCore` depend on
  puzzle-computation internals.
- Benchmarks can be added later to compare internal solver/generator strategies
  without changing public callers.
