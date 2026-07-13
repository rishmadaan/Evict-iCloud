# Evict iCloud — Finder Quick Action App (Design)

**Date:** 2026-07-04
**Status:** Approved
**Scope:** Deliberately minimal. A quick Swift app, not a platform.

## Summary

Rewrite the existing `Evict-iCloud.applescript` as a small native Swift app,
`Evict iCloud.app`, whose primary interface is a **Finder Quick Action**:
right-click any file or folder in iCloud Drive → Quick Actions →
**Evict from iCloud** → local copies are evicted immediately and a
notification confirms the result. The host app window provides a secondary
drag-and-drop path and first-run setup guidance.

Eviction is non-destructive: files remain in iCloud and re-download on
demand. This matches Finder's built-in "Remove Download", which is why the
action fires without a confirmation dialog.

## Decisions (settled during brainstorming)

| Decision | Choice |
|---|---|
| App shape | Finder Quick Action (Action extension) |
| Host app | Setup/status window **plus** working drop zone |
| Action UX | Evict immediately, notify on completion/error (no confirm dialog) |
| Eviction mechanism | Public API `FileManager.evictUbiquitousItem(at:)` everywhere |
| Distribution | Build-from-source (Xcode) now; App Store path documented, not built |
| Sandboxing | Both targets sandboxed from day one (extension is forced to be; host app by choice for App Store readiness) |
| Min target | macOS 14 |

## Architecture

Three small units, one Xcode project:

### 1. `EvictEngine` (shared source file)

One Swift file compiled into **both** targets — no framework, overkill at
this size.

- Entry point: `evict(urls: [URL]) async -> EvictSummary`
- For each URL:
  1. Verify the item is ubiquitous via `URLResourceValues.isUbiquitousItem`.
     Non-iCloud items are rejected up front with a clear reason — never by
     letting the API fail cryptically.
  2. Call `FileManager.evictUbiquitousItem(at:)`.
  3. **Folder fallback:** if eviction of a directory throws (known quirk of
     the API on mixed-state/already-evicted contents), enumerate the tree
     and evict per-file, skipping items whose downloading status says they
     are already dataless.
- Returns `EvictSummary` (evicted / skipped / failed counts + first error
  message) used to compose notification text.

### 2. Action Extension — "Evict from iCloud"

- Sandboxed (mandatory for app extensions).
- `NSExtensionActivationRule`: files **and** folders, multiple selection.
- Flow: receive security-scoped item URLs → run `EvictEngine` → post a user
  notification → complete the extension request. No UI in the normal path.
- Notification copy:
  - Success: `Evicted "Archive" — space is being freed.`
  - Partial: `Evicted 41 of 43 items.` (first error in the body)
  - Not iCloud: `"Notes" is not an iCloud Drive item.`

### 3. Host app (SwiftUI, one window)

- Explains the Quick Action in one or two lines.
- Drop zone wired to the same `EvictEngine`; results shown inline in the
  window (not via notification) since the user is looking at it.
- Best-effort status line showing whether the extension is enabled
  (via `pluginkit` query; degrades to static instructions if unreliable).
- "Open Extension Settings…" button deep-linking to System Settings →
  Extensions (falls back to opening System Settings root if the deep link
  changes across macOS versions).
- Sandboxed with user-selected-file / drag-and-drop read access.

## Error handling

- All extension outcomes surface as notifications; all drop-zone outcomes
  surface inline in the window.
- Non-iCloud items detected via resource values before calling the API.
- Partial failures report counts, not silence.

## Testing

- Real eviction requires a signed-in iCloud account, so automated coverage
  is limited to `EvictEngine`'s walk/skip decision logic.
- The repo gets a short **manual test checklist**:
  1. Evict a folder via Quick Action → cloud icon appears / `brctl status`
     shows dataless.
  2. Open an evicted file → re-downloads on demand.
  3. Evict a non-iCloud folder → clear error notification.
  4. Drop a folder on the host window → same result inline.
  5. Multi-select several files → single summary notification.

## Repo layout

```
Evict-iCloud/
├── EvictiCloud.xcodeproj
├── EvictiCloud/            # host app target
├── EvictAction/            # action extension target
├── Shared/EvictEngine.swift
├── legacy/Evict-iCloud.applescript   # moved, kept for posterity
├── docs/superpowers/specs/
└── README.md               # rewritten: usage, build-from-source, future App Store
```

## Future: Mac App Store (documented, not built now)

The code is already compliant (sandboxed everywhere, public API only,
no shell-outs in the product path). What remains is distribution work:

- Paid Apple Developer account ($99/yr), App Store Connect listing.
- Signing, notarization/upload, review.
- Possible rename if "Evict iCloud" trips Apple-trademark review.

## Known risks

1. **`evictUbiquitousItem` folder quirks** — mitigated by the per-file
   fallback walk. Escape hatch if fully unreliable: `brctl` shell-out from
   the host app only (never the extension). Not expected.
2. **Notifications from an extension** have version-dependent behavior on
   macOS. Validate first during implementation. Fallback: the extension
   briefly presents a small auto-dismissing confirmation panel (Action
   extensions are allowed UI).
3. **Extension-enabled detection** has no clean public API. Best-effort
   only; degrades to static instructions. Not load-bearing.

## Out of scope (YAGNI)

- Menu bar presence, recent-folders list, scheduling/automation,
  preferences window, analytics, auto-update, localization.

## Amendment — 2026-07-13: Quick Action removed, ships drop-zone only

The Finder Quick Action (Action extension) was removed. On macOS 26 the
ad-hoc-signed extension registered and appeared in the Finder menu but the
system never launched its process on click (verified: no process start and no
launch attempt in the unified log, across enabling the extension, replacing the
debug build with a Release build, and de-duplicating LaunchServices records).
The app-extension path is the one Apple polices hardest for unsigned apps.

The app now ships as a drag-and-drop-only utility. The eviction engine
(`EvictEngine` + `EvictReport` + `RealFileOps`) and the sandboxed host window
are unchanged; only the extension delivery mechanism was dropped. A future
reliable right-click path, if wanted, would be an Automator Quick Action
workflow installed by the app — not an app-extension.
