# 0006: Refine Sudoku Package Boundaries

Date: 2026-05-03

2026-05-05 amendment: `SudokuDigit` was narrowed and renamed to `Digit`. Core
digits are plain value identities; fixed digit sets and bounds validation
belong to puzzle configuration or higher-level pipeline code.

2026-05-05 amendment: duplicate scanning was removed from `SudokuCore`. Repeated
digit checks are validation behavior owned by `SudokuDomain` and
`SudokuPuzzleEngine`.

2026-05-05 amendment: `SudokuSquare` was narrowed and renamed to `Position`.
Core positions store only row and column coordinates; index conversion, bounds,
and block membership belong to topology or higher-level code.

2026-05-05 amendment: `SudokuLayout`, `SudokuHouse`, and `SudokuError` were
removed from `SudokuCore`. Standard 9x9 rule topology now lives inside
`SudokuDomain` and `SudokuPuzzleEngine`.

2026-05-06 amendment: `BoardSize` was added to `SudokuCore` as a minimal board
size configuration value. `SudokuDomain.Board` receives a board size value
instead of exposing board dimensions as static properties, and it interprets
that size for cell counts, position indexing, digit bounds, and constraint groups.
`SudokuPuzzleEngine` keeps its internal standard 9x9 topology until engine
configuration becomes necessary.

## Status

Accepted

## Context

The original `SudokuCore` package mixed shared Sudoku vocabulary with
app-facing player grid semantics. `SudokuPuzzleEngine` also repeated standard
9x9 topology helpers for rows, columns, blocks, and duplicate scanning.

This made the package names misleading: the real core should be the vocabulary
and topology shared by every Sudoku module, while clues, entries, and
`cannotChangeClue` belong to the app domain.

## Decision

Keep `SudokuCore` as the shared foundation package. It owns primitive values
such as `Digit` and `Position`, plus minimal Sudoku structure such as
`BoardSize`. It does not define app-facing rule violations, duplicate scan
results, business errors, or engine-facing validation issues.

Create `SudokuDomain` for app-facing Sudoku state. It depends on `SudokuCore`
and owns `Cell`, `Board`, `SudokuRules`, `SudokuRuleViolation`, and
`SudokuDomainError`.

Make `SudokuPuzzleEngine` depend on `SudokuCore` for shared primitive values.
It must not depend on `SudokuDomain`. Its validation API uses `Digit` and
`Position` instead of the old `PuzzleUnit` and integer cell-index result shape.

The app links `SudokuDomain` and `SudokuPuzzleEngine`; `SudokuCore` enters
through package dependencies unless app code directly imports it.

## Consequences

- `SudokuCore` no longer references app-facing board state.
- `SudokuDomain` and `SudokuPuzzleEngine` share foundation types without
  depending on each other.
- Standard 9x9 constants and row, column, and block group generation are
  duplicated internally until a real topology abstraction is needed.
- The puzzle engine validation issue shape is intentionally breaking while the
  API is still early.
- Future difficulty scoring can share a topology abstraction later without
  coupling `SudokuCore` to app player semantics.
