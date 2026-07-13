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

1. Install Xcode (16+) and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
   (`brew install xcodegen`) — or skip XcodeGen and open the committed
   `EvictiCloud.xcodeproj` directly.
2. `xcodegen generate && xcodebuild -project EvictiCloud.xcodeproj -scheme EvictiCloud -configuration Release -derivedDataPath build build`
3. Copy `build/Build/Products/Release/EvictiCloud.app` to `/Applications` and
   launch it.

## How it works

The app calls Apple's public API `FileManager.evictUbiquitousItem(at:)` — no
shell-outs, no private frameworks. If macOS refuses to evict a folder in one
shot (a known quirk), the app walks the folder and evicts file-by-file,
skipping anything already evicted. The app is fully sandboxed.

## Future: Mac App Store

The code is App Store-compliant today (sandboxed, public API only). Shipping
there needs a paid Apple Developer account, notarization, and review — tracked
as a possible future step, not part of this release.

## Legacy

The original AppleScript version lives in [`legacy/`](legacy/) — it shells out
to `brctl evict` and prompts for a single folder.
