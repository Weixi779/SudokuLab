# 0006: Refine Sudoku Package Boundaries

Date: 2026-05-03

2026-05-05 amendment: `SudokuDigit` was narrowed and renamed to `Digit`. Core
digits are plain value identities; fixed digit sets and bounds validation
belong to puzzle configuration or higher-level pipeline code.

2026-05-05 amendment: duplicate scanning was removed from `SudokuCore`. Repeated
digit checks are validation behavior owned by `SudokuDomain` and
`SudokuBoardEngine`.

2026-05-05 amendment: `SudokuSquare` was narrowed and renamed to `Position`.
Core positions store only row and column coordinates; index conversion, bounds,
and block membership belong to topology or higher-level code.

2026-05-05 amendment: `SudokuLayout`, `SudokuHouse`, and `SudokuError` were
removed from `SudokuCore`. Standard 9x9 rule topology now lives inside
`SudokuDomain` and `SudokuBoardEngine`.

2026-05-06 amendment: `BoardSize` was added to `SudokuCore` as a minimal board
size configuration value. `SudokuDomain.Board` receives a board size value
instead of exposing board dimensions as static properties, and it interprets
that size for cell counts, position indexing, digit bounds, and row, column, and
block positions.
`SudokuBoardEngine` keeps its internal standard 9x9 topology until engine
configuration becomes necessary.

2026-05-06 amendment: `SudokuDomain` now owns board solver and generator
contracts. `SudokuBoardEngine` depends on `SudokuDomain` and exposes concrete
algorithm implementations named by strategy, such as `MRVBitmaskBoardSolver`
and `RandomizedBoardGenerator`. Board generation uses copyable configuration on
the generator instance plus a mutating `generate()` effect. `PuzzleGrid` and the
validator family are engine internals, not app-facing API.

2026-05-10 amendment: `BoardSize` was narrowed to a standard-only enum. The
project currently models standard 9x9 Sudoku only. `BoardSize.standard` remains
as shared vocabulary for board dimensions, but `SudokuDomain.Board` no longer
accepts arbitrary size injection and solver/generator contracts no longer expose
unsupported-size errors.

2026-05-10 amendment: `BoardTopology` was extracted as a public
`SudokuDomain` value. `Board` exposes its topology and delegates position,
row, column, block, and index behavior to it.

## Status

Accepted

## Context

The original `SudokuCore` package mixed shared Sudoku vocabulary with
app-facing player grid semantics. `SudokuBoardEngine` also repeated standard
9x9 topology helpers for rows, columns, blocks, and duplicate scanning.

This made the package names misleading: the real core should be the vocabulary
and topology shared by every Sudoku module, while clues, entries, and
`cannotChangeClue` belong to the app domain.

## Decision

Keep `SudokuCore` as the shared foundation package. It owns primitive values
such as `Digit` and `Position`, plus standard board vocabulary such as
`BoardSize`. It does not define app-facing rule violations, duplicate scan
results, business errors, or engine-facing validation issues.

Create `SudokuDomain` for app-facing Sudoku state. It depends on `SudokuCore`
and owns `Cell`, `Board`, `BoardTopology`, `Rule`, `Violation`, `RowRule`,
`ColumnRule`, `BlockRule`, `RowsRule`, `ColumnsRule`, `BlocksRule`,
`UniqueRule`, `SudokuDomainError`, `BoardSolver`, and `BoardGenerator`.

Make `SudokuBoardEngine` depend on `SudokuDomain` and `SudokuCore`. Its public
surface implements Domain's board contracts, while numeric `PuzzleGrid` and
throwing validator types stay internal to the engine package.

The app links `SudokuDomain` and `SudokuBoardEngine`; `SudokuCore` enters
through package dependencies unless app code directly imports it.

## Consequences

- `SudokuCore` no longer references app-facing board state.
- `SudokuBoardEngine` now depends on `SudokuDomain`, making Domain the shared
  board vocabulary for solver and generator use.
- `BoardTopology` owns standard row, column, block, position, and index
  behavior. `Board` exposes a topology and uses it for cell access, but it does
  not own validation rules. `RowRule`, `ColumnRule`, and `BlockRule` each
  validate one concrete row, column, or block. `RowsRule`, `ColumnsRule`, and
  `BlocksRule` aggregate those single rules for a board. `UniqueRule` composes
  the three aggregate rules to model standard Sudoku uniqueness.
- The board engine public API intentionally breaks from `Solver`/`Generator`
  and `PuzzleGrid` to Board-first contracts while the API is still early.
- Engine algorithms and future difficulty scoring can share `BoardTopology`
  without coupling `SudokuCore` to app player semantics.
