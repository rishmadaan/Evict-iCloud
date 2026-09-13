// Copyright (c) 2026 Rishabh Madaan
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Evict iCloud.
//
// Evict iCloud is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Evict iCloud is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Evict iCloud. If not, see <https://www.gnu.org/licenses/>.

import Foundation

public enum EvictReport {
    public static func message(for summary: EvictSummary, items: [URL]) -> (title: String, body: String) {
        if summary.evicted == 0 && summary.failed == 0 && summary.skipped == 0,
           let bad = summary.notUbiquitous.first {
            return ("Evict iCloud", "\u{201C}\(bad)\u{201D} is not an iCloud Drive item.")
        }
        if summary.failed > 0 {
            let total = summary.evicted + summary.failed
            return ("Evicted \(summary.evicted) of \(total) items",
                    summary.firstError ?? "Some items could not be evicted.")
        }
        let name = items.count == 1
            ? "\u{201C}\(items[0].lastPathComponent)\u{201D}"
            : "\(items.count) items"
        return ("Evicted \(name)", "Space is being freed.")
    }
}
