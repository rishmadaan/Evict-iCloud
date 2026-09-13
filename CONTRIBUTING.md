# Contributing

Contributions to Evict iCloud are accepted under GNU GPL version 3 or, at the
recipient's option, any later version (`GPL-3.0-or-later`); see [LICENSE](LICENSE).
By submitting a contribution, you agree to license it under those terms and
confirm that you have the right to do so. You retain your copyright.

Identify any third-party material and its license when submitting it. Preserve
its copyright and license notices, and ensure its terms are compatible with
the project license. Do not replace third-party notices with project notices.

Keep changes focused. For behavior changes, run the existing Xcode tests and
the relevant [manual checks](docs/manual-test-checklist.md) on macOS. Changes to
`project.yml` must also be reflected in the committed Xcode project by running
`xcodegen generate`.
