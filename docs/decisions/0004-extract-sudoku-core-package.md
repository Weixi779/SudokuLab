# 0004: Extract SudokuCore Package

Date: 2026-05-01

## Status

Accepted, amended by [0006](0006-refine-sudoku-package-boundaries.md)

2026-05-03 amendment: app-facing grid and player rule semantics moved to
`SudokuDomain`; `SudokuCore` now owns only shared primitive values.

## Context

Sudoku domain models and rules need to remain independent from SwiftUI,
SwiftData, and app dependency injection. Keeping this logic in the app target
makes those boundaries easier to erode as the UI grows.

Sudoku terminology is also stable enough to encode in public API names. A
standard puzzle is a 9x9 grid with rows, columns, blocks, cells, clues, and
entries.

## Decision

Create a local Swift package named `SudokuCore` under
`SudokuLab/Packages/SudokuCore`.

The package originally owned the pure Swift Sudoku domain model and rule
validation. After ADR 0006, `SudokuCore` owns only shared primitive values and
`SudokuDomain` owns app-facing grid, public `BoardTopology`, and player rule
validation.

Solving, solution counting, generation, and difficulty scoring belong in a
separate pure board engine package. After the 2026-05-06 ADR 0006 amendment,
that package depends on `SudokuDomain` for board solver/generator contracts and
on `SudokuCore` for shared primitive values.

Public API terms use:

- `Digit` for a symbol identity.
- `Position` for a row and column coordinate.

These terms align with Nikoli's
[`Sudoku` rules](https://www.nikoli.com/en/puzzles/sudoku/),
[WPF Sudoku GP](https://gp.worldpuzzle.org/sites/default/files/Puzzles/2015/2015_SudokuRound1_IB_v1.pdf)
wording for rows, columns, and outlined 3x3 regions, and common Sudoku glossary
usage.

## Consequences

- App targets can depend on `SudokuDomain` and `SudokuBoardEngine`, while
  `SudokuCore` remains free of SwiftUI, SwiftData, FactoryKit, and
  FactoryTesting.
- `SudokuCore` is intentionally small enough to build without a dedicated test
  target; Domain and Engine tests cover its use through public contracts.
- App unit tests remain focused on app shell and store behavior.
- Future app stores and persistence records should consume `SudokuDomain`
  models rather than reimplementing player-grid rules.
