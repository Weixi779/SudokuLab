# 17-Clue Puzzle Notes

Standard 9x9 Sudoku puzzles with a unique solution cannot have fewer than
17 givens. A 17-clue puzzle means 17 known cells and 64 empty cells.

Important product notes:

- 17-clue does not automatically mean "hardest" for a human solver.
- Human difficulty should eventually be based on solving techniques and search
  complexity, not only on clue count.
- The set of valid 9x9 Sudoku puzzles is finite, so 17-clue puzzles are finite
  too.
- Extreme puzzles are better treated as datasets or cacheable resources than as
  puzzles the app must generate live.

Recommended direction:

- Generate normal puzzles locally.
- Keep the app playable offline.
- Add bundled or cached extreme puzzle sets later.
- Treat remote puzzle APIs as optional import/update sources.
