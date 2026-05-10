# Roadmap

## Phase 0: Project Foundation

- Create the `SudokuLab` shell.
- Keep the legacy `Sudoku-Demo` app as migration reference.
- Add README, agent rules, formatter configuration, and architecture docs.
- Keep CloudKit and TCA out of the active baseline.

## Phase 1: App Shell

- Replace the SwiftData template screen with the first real app shell.
- Establish `App`, `Features`, `Shared`, `Infrastructure`, and `Resources`
  folders inside the new project.
- Add FactoryKit and register initial local services.
- Add a minimal theme system and app settings surface.

## Phase 2: Sudoku Packages

- Extract shared Sudoku primitive values into a pure Swift `SudokuCore` package.
- Extract the app-facing grid, cells, clues, entries, and player rule validator
  into a pure Swift `SudokuDomain` package.
- Extract the pure Swift `SudokuBoardEngine` package for solving, solution
  counting, uniqueness checks, generation, and future rating.
- Add deterministic solver, uniqueness, and generated-puzzle tests with seeded
  randomness.

## Phase 3: Game Feature

- Build the modern game board UI.
- Implement selection, fill mode, notes, delete, restart, completion detection,
  and timer state through an observable store.
- Keep UI independent from solving/generation internals.

## Phase 4: Persistence

- Store unfinished games, completed games, statistics, and settings in SwiftData.
- Support resuming multiple unfinished games.
- Define migration rules before changing stored models.

## Phase 5: Puzzle Library

- Add local puzzle cache and bundled puzzle sets.
- Evaluate 17-clue datasets as versioned resources.
- Treat remote APIs as optional import/update sources, not as core gameplay
  dependencies.

## Phase 6: App Store Readiness

- Finalize app icon, display name, privacy details, and screenshots.
- Audit accessibility, localization, performance, and offline behavior.
- Revisit CloudKit only if cross-device sync is a concrete product goal.
