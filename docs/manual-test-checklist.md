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
