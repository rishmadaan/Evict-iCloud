# Manual test checklist

Run before tagging a release. Requires a signed-in iCloud account with
iCloud Drive enabled and at least one folder of downloaded files.

1. **Drop a folder:** open the app and drop a downloaded iCloud Drive folder
   onto the window. Expect the result line to report the eviction and the
   folder's contents to show cloud-download icons in Finder.
2. **Re-download:** open one evicted file. Expect it to download and open.
3. **Non-iCloud item:** drop a folder from outside iCloud Drive. Expect
   "… is not an iCloud Drive item."
4. **Multi-select:** drop several files at once. Expect one summary line.
5. **Already evicted:** drop the same folder again. Expect a skip-heavy
   summary and no errors.

## License and release checks

1. On macOS, build the committed project, then run `xcodegen generate` and build
   again. Both builds must include `Contents/Resources/LICENSE` and
   `Contents/Resources/Credits.rtf` in the app bundle. Compare the bundled
   `LICENSE` with the repository's `LICENSE`; they must match exactly.
2. With networking disabled, open **About Evict iCloud** from the application
   menu. Verify the copyright, GPL v3-or-later grant, warranty disclaimer, and
   complete GPL v3 text appear and can be scrolled through to the end.
3. Run the existing tests:
   `xcodebuild -project EvictiCloud.xcodeproj -scheme EvictiCloud -destination 'platform=macOS' test`.
4. Check current notices consistently use `GPL-3.0-or-later`. Historical MIT
   references describe earlier versions only. Preserve any third-party notices.
5. Before the first GPL release, confirm ownership/provenance of included code
   and assets. The local branch history attributes the code to rishmadaan;
   authorship metadata alone does not establish copyright ownership. No external
   runtime packages or vendored code were identified during the migration.
6. For each binary download, provide the exact corresponding source archive at
   the same download location, at no additional charge. Include the source,
   license, notices, `project.yml`, committed Xcode project, and build instructions
   needed for that version. Do not link only to a changing default branch.
7. Tag the tested release commit. For the first GPL release, state in the release
   notes that it uses GPL-3.0-or-later and earlier MIT copies retain their original
   terms. Confirm GitHub recognizes GPL v3 after publication. Do not rewrite old
   tags or history. No release was created as part of the local migration.
8. Before any Mac App Store release, review Apple's applicable terms against GPL
   distribution rights. That review remains separate from technical app testing.

Licensing references: [GNU's application guide](https://www.gnu.org/licenses/gpl-howto.en.html)
and [GPL v3, particularly section 6](https://www.gnu.org/licenses/gpl-3.0.html).
