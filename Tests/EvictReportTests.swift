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

import XCTest

final class EvictReportTests: XCTestCase {
    let archive = URL(fileURLWithPath: "/iCloud/Archive", isDirectory: true)
    let notes = URL(fileURLWithPath: "/Users/rish/Notes")

    func test_successCopyForSingleItem() {
        var s = EvictSummary(); s.evicted = 12
        let m = EvictReport.message(for: s, items: [archive])
        XCTAssertEqual(m.title, "Evicted \u{201C}Archive\u{201D}")
        XCTAssertEqual(m.body, "Space is being freed.")
    }

    func test_partialCopyReportsCounts() {
        var s = EvictSummary(); s.evicted = 41; s.failed = 2; s.firstError = "boom"
        let m = EvictReport.message(for: s, items: [archive])
        XCTAssertEqual(m.title, "Evicted 41 of 43 items")
        XCTAssertEqual(m.body, "boom")
    }

    func test_notICloudCopy() {
        var s = EvictSummary(); s.notUbiquitous = ["Notes"]
        let m = EvictReport.message(for: s, items: [notes])
        XCTAssertEqual(m.title, "Evict iCloud")
        XCTAssertEqual(m.body, "\u{201C}Notes\u{201D} is not an iCloud Drive item.")
    }
}
