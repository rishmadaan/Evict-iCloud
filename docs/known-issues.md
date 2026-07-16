# Known issues (accepted at v2 merge review)

Cosmetic or edge-case items triaged as non-blocking at the final branch
review (2026-07-04). Fix opportunistically.

- **Mixed-selection copy:** the success title counts all dropped items, so a
  selection where some items were not in iCloud reads as if all were evicted;
  not-in-iCloud items are unmentioned when anything else succeeds; already-
  evicted (skipped) items are excluded from "Evicted N of M" totals.
  (`Shared/EvictReport.swift`)
- **Drop-zone status line races** if a second drop lands while one is running
  (last writer wins; self-corrects). (`EvictiCloud/ContentView.swift`)
- **Swift 6 strict concurrency:** the detached task in `ContentView.evict`
  captures `self`; fine in Swift 5.9 mode, needs restructuring on a language-
  mode bump.
- **project.yml:** the test target's `GENERATE_INFOPLIST_FILE` is a required,
  deliberate deviation; do not "simplify" it away. It needs an explanatory
  comment.
- **Enumerator failures are invisible:** `RealFileOps.filesUnder` passes no
  `errorHandler`, so a failed walk looks like an empty folder. Revisit after
  live-iCloud verification.
