# 0004: Extract SudokuCore Package

Date: 2026-05-01

## Status

Accepted

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

The package owns the pure Swift Sudoku domain model and rule validation. It
currently supports only standard 9x9 Sudoku. The size constants remain
centralized as validation checks rather than scattered literals. Dynamic sizes,
4x4 puzzles, 16x16 puzzles, candidate notes, and peers are future decisions.

Solving, solution counting, generation, and difficulty scoring belong in a
separate pure puzzle engine package. That package must stay independent from
`SudokuCore`; app features or adapters compose the two packages.

Public API terms use:

- `Grid` for the whole 9x9 puzzle state.
- `Square` for a position identity within the grid.
- `Cell` for the content state at a square.
- `House` for a row, column, or block.
- `Clue` for an initial fixed digit.
- `Entry` for a user-filled digit.

These terms align with Nikoli's
[`Sudoku` rules](https://www.nikoli.com/en/puzzles/sudoku/),
[WPF Sudoku GP](https://gp.worldpuzzle.org/sites/default/files/Puzzles/2015/2015_SudokuRound1_IB_v1.pdf)
wording for rows, columns, and outlined 3x3 regions, and common Sudoku glossary
usage.

## Consequences

- App targets can depend on `SudokuCore`, but `SudokuCore` does not depend on
  SwiftUI, SwiftData, FactoryKit, or FactoryTesting.
- Core tests run in the package test target and use ordinary `import
  SudokuCore` to verify the public API boundary.
- App unit tests remain focused on app shell and store behavior.
- Future app stores and persistence records should consume the package model
  rather than reimplementing Sudoku rules.
