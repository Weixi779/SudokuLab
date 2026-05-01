# Agent Guidelines

These rules apply to the active `SudokuLab` rebuild. The old `Sudoku-Demo`
project is reference material unless a task explicitly asks to edit it.

## Project Direction

- Build the active app in `SudokuLab/`.
- Keep the minimum deployment target on iOS 26+.
- Use SwiftUI, Swift Observation, SwiftData, and FactoryKit.
- Do not introduce TCA into the active architecture.
- Do not add CloudKit until the local SwiftData model is stable and there is a
  clear sync requirement.
- Keep Sudoku solving and generation independent from SwiftUI and persistence.

## Architecture Rules

- Prefer pure Swift models and services for Sudoku rules, solving, generation,
  validation, and difficulty scoring.
- Keep app-facing state in small `@Observable` stores.
- Inject infrastructure through protocols and FactoryKit registrations.
- SwiftData models should be persistence records, not the source of all business
  logic.
- Views should render state and call store methods; avoid putting game rules in
  SwiftUI view bodies.

## Documentation

- Update `README.md` when setup, project names, or major commands change.
- Record long-term direction and tradeoffs in `docs/`.
- Use ADR-style decision files under `docs/decisions/` for architecture choices
  that should not be rediscovered later.

## Code Style

- Use English for code comments and public API documentation.
- Keep user-facing product copy in the language required by the UI design.
- Format Swift code with:

```sh
swift format format --recursive --in-place --parallel --configuration .swift-format \
  SudokuLab/SudokuLab SudokuLab/SudokuLabTests SudokuLab/SudokuLabUITests
```

## Git Safety

- Do not revert user changes unless explicitly asked.
- Keep legacy migration commits small and reviewable.
- Do not mix broad formatting with behavior changes.
