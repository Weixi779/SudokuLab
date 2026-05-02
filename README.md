# SudokuLab

SudokuLab is a modern rebuild of an older SwiftUI Sudoku project. The original
app completed its graduation-project purpose; this repository now uses that
history as reference material while the active app moves into a cleaner iOS
26+ codebase.

The project is intentionally small, but it should be treated like a real app:
clear boundaries, testable Sudoku logic, local-first persistence, and a SwiftUI
interface that can evolve without carrying old architectural debt.

## Current Status

- Active project: `SudokuLab/SudokuLab.xcodeproj`
- Legacy reference project: `Sudoku-Demo.xcodeproj` and `Sudoku-Demo/`
- Minimum deployment target: iOS 26.0
- Persistence direction: SwiftData, local-only when models are introduced
- Dependency injection: FactoryKit 3.0.1
- Test dependency helpers: FactoryTesting
- Architecture direction: Swift Observation stores plus lightweight services
- TCA: not part of the active architecture
- CloudKit: deferred until the local data model is stable

## Goals

- Rebuild the app shell under the `SudokuLab` name.
- Keep Sudoku domain models and puzzle computation in pure Swift packages.
- Keep game state, persistence, and UI separated enough to test each layer.
- Support themes, game progress, history, and statistics through local data.
- Keep the app offline-first, with remote puzzle sources treated as optional
  future inputs rather than core runtime dependencies.

## Repository Layout

```text
SudokuLab/
  SudokuLab.xcodeproj       New active Xcode project
  Packages/
    SudokuCore/             Pure Swift Sudoku domain grid and rule model
    SudokuPuzzleEngine/     Pure Swift Sudoku solving, validation, and generation
  SudokuLab/                App source
    App/                    App root view, tabs, and root store
    Features/               Feature root screens
    Infrastructure/DI/      FactoryKit registrations and app dependency entrypoints
    Resources/              Asset catalogs and app resources
  SudokuLabTests/           Unit tests
  SudokuLabUITests/         UI tests

Sudoku-Demo/                Legacy app source kept as reference during migration
Sudoku-Demo.xcodeproj       Legacy Xcode project
docs/                       Architecture notes, roadmap, and decisions
AGENTS.md                   Working rules for coding agents
```

The target structure for the new app is documented in
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Development

Open the new project:

```sh
open SudokuLab/SudokuLab.xcodeproj
```

List schemes from the command line:

```sh
xcodebuild -list -project SudokuLab/SudokuLab.xcodeproj
```

Format Swift code with the bundled Swift formatter:

```sh
swift format format --recursive --in-place --parallel --configuration .swift-format \
  SudokuLab/SudokuLab SudokuLab/SudokuLabTests SudokuLab/SudokuLabUITests \
  SudokuLab/Packages/SudokuCore SudokuLab/Packages/SudokuPuzzleEngine
```

Run the Sudoku core package tests:

```sh
swift test --package-path SudokuLab/Packages/SudokuCore
```

Run the Sudoku puzzle engine package tests:

```sh
swift test --package-path SudokuLab/Packages/SudokuPuzzleEngine
```

Lint Swift formatting:

```sh
swift format lint --recursive --configuration .swift-format \
  SudokuLab/SudokuLab SudokuLab/SudokuLabTests SudokuLab/SudokuLabUITests \
  SudokuLab/Packages/SudokuCore SudokuLab/Packages/SudokuPuzzleEngine
```

Check for whitespace errors before committing:

```sh
git diff --check
```

For pure Swift package changes, prefer the SwiftPM test and formatter checks
above. Run Xcode builds separately when validating app target integration or UI
behavior, because simulator and user-cache access can be environment-specific.

Resolve Swift packages:

```sh
xcodebuild -resolvePackageDependencies -project SudokuLab/SudokuLab.xcodeproj
```

Use the legacy project only as source material while rebuilding. New production
work should land in `SudokuLab/`.
