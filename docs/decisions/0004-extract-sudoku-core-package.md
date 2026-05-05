# 0004: Extract SudokuCore Package

Date: 2026-05-01

## Status

Accepted, amended by [0006](0006-refine-sudoku-package-boundaries.md)

2026-05-03 amendment: app-facing grid and player rule semantics moved to
`SudokuDomain`; `SudokuCore` now owns only shared topology, coordinate, digit,
house, and duplicate primitives.

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
validation. After ADR 0006, `SudokuCore` owns the shared foundation and
`SudokuDomain` owns app-facing grid and player rule validation. The shared
foundation currently supports only standard 9x9 Sudoku. Dynamic sizes, 4x4
puzzles, 16x16 puzzles, candidate notes, and peers are future decisions.

Solving, solution counting, generation, and difficulty scoring belong in a
separate pure puzzle engine package. After ADR 0006, that package depends on
`SudokuCore` for shared topology but remains independent from `SudokuDomain`.

Public API terms use:

- `Grid` for the whole 9x9 puzzle state.
- `Position` for a row and column coordinate.
- `Cell` for the content state at a position.
- `House` for a row, column, or block.
- `Clue` for an initial fixed digit.
- `Entry` for a user-filled digit.

These terms align with Nikoli's
[`Sudoku` rules](https://www.nikoli.com/en/puzzles/sudoku/),
[WPF Sudoku GP](https://gp.worldpuzzle.org/sites/default/files/Puzzles/2015/2015_SudokuRound1_IB_v1.pdf)
wording for rows, columns, and outlined 3x3 regions, and common Sudoku glossary
usage.

## Consequences

- App targets can depend on `SudokuDomain` and `SudokuPuzzleEngine`, while
  `SudokuCore` remains free of SwiftUI, SwiftData, FactoryKit, and
  FactoryTesting.
- Core tests run in the package test target and use ordinary `import
  SudokuCore` to verify the public API boundary.
- App unit tests remain focused on app shell and store behavior.
- Future app stores and persistence records should consume `SudokuDomain`
  models rather than reimplementing player-grid rules.
