# Architecture

SudokuLab is a local-first SwiftUI app built around a clean separation between
Sudoku logic, app state, persistence, and UI.

## Layers

```text
App
  Composition root, scene setup, dependency registration

Features
  Home, Game, Settings, Records
  SwiftUI views plus small observable stores

Core
  Sudoku board, puzzle, solver, generator, validation, difficulty scoring
  No SwiftUI, no SwiftData, no FactoryKit

Infrastructure
  SwiftData repositories, puzzle providers, cache, clocks, random sources

Shared
  Theme system, reusable controls, extensions, design tokens
```

The future `SudokuCore` package should own the `Core` layer. It should compile
and test without the app target.

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
