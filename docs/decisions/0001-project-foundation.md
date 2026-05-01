# 0001: Rebuild Under SudokuLab

Date: 2026-05-01

## Status

Accepted

## Context

The original `Sudoku-Demo` project was written during an early learning stage
and mixes SwiftUI, persistence, game state, and Sudoku generation in ways that
make modern changes harder than necessary.

The project is small enough that a clean shell is cheaper than a long,
piecemeal Xcode project cleanup.

## Decision

Create a new active project named `SudokuLab` and keep the old project as
reference during migration.

The active app will use:

- iOS 26+
- SwiftUI
- Swift Observation
- SwiftData for local persistence
- FactoryKit for dependency injection
- A future pure Swift `SudokuCore` package

## Consequences

- New production work should land in `SudokuLab/`.
- Legacy code can be copied or rewritten only when it earns its place.
- The old project can be removed once the new app reaches feature parity or
  enough behavior has been migrated and tested.
