# Known issues (accepted at v2 merge review)

Cosmetic or edge-case items triaged as non-blocking at the final branch
review (2026-07-04). Fix opportunistically.

- **Mixed-selection copy:** the success title counts all dropped items, so a
  selection where some items were not in iCloud reads as if all were evicted;
  not-in-iCloud items are unmentioned when anything else succeeds; already-
  evicted (skipped) items are excluded from "Evicted N of M" totals.
  (`Shared/EvictReport.swift`)
- **Silently dropped attachments:** items whose `loadItem` fails are omitted
  from the summary. An all-items-failed selection now gets distinct copy, but
  partial load failures under-report. (`EvictAction/ActionRequestHandler.swift`)
- **Swallowed notification errors:** denied notification permission is
  indistinguishable from success (`try?` on authorization/add).
- **Drop-zone status line races** if a second drop lands while one is running
  (last writer wins; self-corrects). (`EvictiCloud/ContentView.swift`)
- **Swift 6 strict concurrency:** the detached task in `ContentView.evict`
  captures `self`; fine in Swift 5.9 mode, needs restructuring on a language-
  mode bump.
- **project.yml:** the extension's nested bundle ID and the test target's
  `GENERATE_INFOPLIST_FILE` are required, deliberate deviations — do not
  "simplify" them away; they need explanatory comments.
- **README:** build step 2 starts with `xcodegen generate`, which fails for
  users who took the "open the committed xcodeproj" path; the System Settings
  extensions pane location varies by macOS version. Wording polish pending.
- **Enumerator failures are invisible:** `RealFileOps.filesUnder` passes no
  `errorHandler`, so a failed walk looks like an empty folder. Revisit after
  live-iCloud verification.
