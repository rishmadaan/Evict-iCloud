# Evict iCloud (macOS)

Free disk space by evicting the local copies of iCloud Drive files — exactly
what Finder's **Remove Download** does, but for a whole folder at once by drag
and drop.

Files stay safe in iCloud and re-download on demand. Nothing is deleted.

## Usage

Open **Evict iCloud.app** and drop any iCloud Drive files or folders onto the
window. The local copies are removed and the freed space returns within a few
seconds. The window shows what happened after each drop.

## Requirements

- macOS 14 Sonoma or later
- iCloud Drive enabled (System Settings → Apple ID → iCloud)

## Build from source

Prebuilt binaries are not provided (yet — see below). Building takes a minute:

1. Install Xcode (16+).
2. `xcodebuild -project EvictiCloud.xcodeproj -scheme EvictiCloud -configuration Release -derivedDataPath build build`
3. Copy `build/Build/Products/Release/EvictiCloud.app` to `/Applications` and
   launch it.

## How it works

The app calls Apple's public API `FileManager.evictUbiquitousItem(at:)` — no
shell-outs, no private frameworks. If macOS refuses to evict a folder in one
shot (a known quirk), the app walks the folder and evicts file-by-file,
skipping anything already evicted. The app is fully sandboxed.

## Future: Mac App Store

The app is sandboxed and uses public APIs. Mac App Store distribution remains
a possible future step: Apple's applicable distribution terms must be reviewed
for compatibility with GPL rights before a store release. Technical readiness
alone does not establish license compatibility. Source distribution is the
current release path.

## Legacy

The original AppleScript version lives in [`legacy/`](legacy/) — it shells out
to `brctl evict` and prompts for a single folder.

## License

Copyright (c) 2025-2026 Rishabh Madaan.

Evict iCloud is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version
(`GPL-3.0-or-later`). This covers the project-owned app, shared code, tests,
legacy AppleScript, documentation, and build configuration unless otherwise noted.
Apple frameworks and external development tools retain their own licenses.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See [LICENSE](LICENSE) for the full terms. The app's
**About Evict iCloud** panel also includes the full license for offline reading.

The GPL migration follows commit
[`411d2c5`](https://github.com/rishmadaan/Evict-iCloud/commit/411d2c5bc59813ba80459a787b867fae3328d9ea).
Copies previously distributed under MIT remain under those terms; this change
does not withdraw their existing permissions. Subsequent project releases use
GPL-3.0-or-later unless explicitly stated otherwise.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution terms and
[the release checklist](docs/manual-test-checklist.md#license-and-release-checks)
for distributing binaries with their corresponding source.
