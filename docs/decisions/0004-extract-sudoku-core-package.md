# 0004: Extract SudokuCore Package

Date: 2026-05-01

## Status

Accepted

## Context

Sudoku rules, grid validation, solving, generation, and future difficulty
scoring need to remain independent from SwiftUI, SwiftData, and app dependency
injection. Keeping this logic in the app target makes those boundaries easier
to erode as the UI grows.

Sudoku terminology is also stable enough to encode in public API names. A
standard puzzle is a 9x9 grid with rows, columns, boxes, cells, clues, and
entries.

## Decision

Create a local Swift package named `SudokuCore` under
`SudokuLab/Packages/SudokuCore`.

The package owns the pure Swift Sudoku model and currently supports only
standard 9x9 Sudoku. The size constants remain centralized as validation checks
rather than scattered literals. Dynamic sizes, 4x4 puzzles, 16x16 puzzles,
candidate notes, peers, solving, generation, and difficulty scoring are future
decisions.

Public API terms use:

- `Grid` for the whole 9x9 puzzle state.
- `Square` for a position identity within the grid.
- `Cell` for the content state at a square.
- `House` for a row, column, or box.
- `Clue` for an initial fixed digit.
- `Entry` for a user-filled digit.

These terms follow common Sudoku glossary usage, including Wikipedia's
[`Glossary of Sudoku`](https://en.wikipedia.org/wiki/Glossary_of_Sudoku) and
SudokuWiki's [`Glossary`](https://www.sudokuwiki.org/Print_Glossary).

## Consequences

- App targets can depend on `SudokuCore`, but `SudokuCore` does not depend on
  SwiftUI, SwiftData, FactoryKit, or FactoryTesting.
- Core tests run in the package test target and use ordinary `import
  SudokuCore` to verify the public API boundary.
- App unit tests remain focused on app shell and store behavior.
- Future app stores and persistence records should consume the package model
  rather than reimplementing Sudoku rules.
