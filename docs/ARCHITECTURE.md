# Architecture

SudokuLab is a local-first SwiftUI app built around a clean separation between
Sudoku logic, app state, persistence, and UI.

## Layers

```text
App
  Composition root, scene setup, root tabs

Features
  Home, Game, Settings, Records
  SwiftUI views plus small observable stores

Core packages
  SudokuCore shared Sudoku topology, coordinates, houses, and duplicate primitives
  SudokuDomain app-facing domain model, clues, entries, and player rule validation
  SudokuPuzzleEngine pure solving, validation, solution counting, generation,
  and rating
  No SwiftUI, no SwiftData, no FactoryKit

Infrastructure
  FactoryKit registration, SwiftData repositories, puzzle providers, cache,
  clocks, random sources

Shared
  Theme system, reusable controls, extensions, design tokens
```

`SudokuCore` owns only shared Sudoku foundation types and topology helpers.
`SudokuDomain` owns the app-facing player grid model. `SudokuPuzzleEngine` owns
pure puzzle computation. `SudokuDomain` and `SudokuPuzzleEngine` may depend on
`SudokuCore`, but they must not depend on each other. The app composes domain
and engine behavior through feature stores and adapters.

## State Management

The active app should use Swift Observation instead of TCA.

Suggested stores:

- `GameStore`: active puzzle, selection, notes, elapsed time, completion state.
- `SettingsStore`: theme, user preferences, app configuration.
- `LibraryStore`: unfinished games, history, saved puzzle sources.

Stores should expose intent methods such as `selectCell`, `fill`, `toggleNote`,
`startNewGame`, and `resumeGame`. SwiftUI views should not duplicate game rules.

## Dependency Injection

FactoryKit is the planned DI layer. The app should depend on protocols for
infrastructure:

- `PuzzleGenerating`
- `PuzzleSolving`
- `GameProgressRepository`
- `GameRecordRepository`
- `SettingsRepository`
- `Clock`
- `UUIDProviding`
- `RandomNumberGenerating`

Production implementations live in infrastructure. Tests use fakes.

The test target should use FactoryTesting, not a direct FactoryKit import.
App-owned dependency entrypoints can expose the resolved objects that tests need
without duplicating factories in the test module.

## Persistence

SwiftData is the local persistence baseline. Initial models should prioritize
stable identity and migration safety:

- `GameProgressRecord`
- `GameRecord`
- `AppSettingsRecord`
- `PuzzleCacheRecord`

CloudKit is intentionally deferred. The local model should still use stable ids
and timestamps so sync can be added later without reshaping the domain.

## Puzzle Sources

Normal puzzles should be generated locally. Extreme puzzle sets, such as
17-clue puzzles, should be treated as finite datasets or cacheable resources
rather than runtime requirements for the app to function.
