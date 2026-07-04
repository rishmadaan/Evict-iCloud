# Manual test checklist

Run before tagging a release. Requires a signed-in iCloud account with
iCloud Drive enabled and at least one folder of downloaded files.

1. **Quick Action, folder:** right-click an iCloud Drive folder → Quick
   Actions → Evict from iCloud. Expect a notification "Evicted …" and
   cloud-download icons on the folder's contents (`brctl status` can
   confirm dataless state).
2. **Re-download:** open one evicted file. Expect it to download and open.
3. **Non-iCloud item:** run the Quick Action on a folder outside iCloud
   Drive. Expect "… is not an iCloud Drive item."
4. **Multi-select:** select several files → Quick Action. Expect one summary
   notification.
5. **Drop zone:** drop an iCloud folder on the app window. Expect the same
   result inline in the window.
6. **Already evicted:** run the Quick Action again on the same folder.
   Expect a skip-heavy summary and no errors.
