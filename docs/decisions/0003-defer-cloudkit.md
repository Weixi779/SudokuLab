# 0003: Defer CloudKit

Date: 2026-05-01

## Status

Accepted

## Context

Cross-device sync could be useful for unfinished games, history, and settings.
However, CloudKit would add entitlements, iCloud account behavior, model
constraints, merge behavior, and extra App Store review considerations before
the local data model is proven.

## Decision

Do not add CloudKit to the initial shell.

Use SwiftData locally first. Design records with stable ids and timestamps so a
future sync layer remains possible.

## Consequences

- The first rebuild stays offline-first.
- Local persistence can evolve without CloudKit constraints in the earliest
  phase.
- CloudKit can be reconsidered after the SwiftData model and product need are
  clear.
