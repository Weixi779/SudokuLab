# 0002: Do Not Use TCA For The Active Rebuild

Date: 2026-05-01

## Status

Accepted

## Context

The project previously experimented with TCA, but the active app does not have
enough routing, cross-feature communication, or effect orchestration to justify
that framework's weight today.

TCA may become more attractive after its 2.0 direction settles, but adopting it
now would move attention away from the project's real boundaries: Sudoku logic,
game state, persistence, and UI.

## Decision

Do not use TCA in the active `SudokuLab` architecture.

Use Swift Observation stores, protocol-oriented services, and FactoryKit for
dependency registration instead.

## Consequences

- Existing or historical TCA code is not a migration target.
- We can revisit TCA later if the app grows into a shape where it clearly helps.
- Tests should focus on pure Sudoku logic and observable store behavior.
