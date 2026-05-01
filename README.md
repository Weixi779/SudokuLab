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
- Minimum deployment target: iOS 26.4
- Persistence baseline: SwiftData, local-only for now
- Dependency injection direction: FactoryKit
- Architecture direction: Swift Observation stores plus lightweight services
- TCA: not part of the active architecture
- CloudKit: deferred until the local data model is stable

## Goals

- Rebuild the app shell under the `SudokuLab` name.
- Extract Sudoku solving and puzzle generation into a pure Swift package.
- Keep game state, persistence, and UI separated enough to test each layer.
- Support themes, game progress, history, and statistics through local data.
- Keep the app offline-first, with remote puzzle sources treated as optional
  future inputs rather than core runtime dependencies.

## Repository Layout

```text
SudokuLab/
  SudokuLab.xcodeproj       New active Xcode project
  SudokuLab/                App source
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
  SudokuLab/SudokuLab SudokuLab/SudokuLabTests SudokuLab/SudokuLabUITests
```

Use the legacy project only as source material while rebuilding. New production
work should land in `SudokuLab/`.
