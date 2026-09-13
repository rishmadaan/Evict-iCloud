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

final class MockFileOps: FileOps {
    var ubiquitous: Set<URL> = []
    var directories: Set<URL> = []
    var dataless: Set<URL> = []
    var failing: Set<URL> = []
    var tree: [URL: [URL]] = [:]
    var evictedURLs: [URL] = []

    struct Fail: LocalizedError { var errorDescription: String? = "simulated eviction failure" }

    func isUbiquitous(_ url: URL) -> Bool { ubiquitous.contains(url) }
    func isDirectory(_ url: URL) -> Bool { directories.contains(url) }
    func isDataless(_ url: URL) -> Bool { dataless.contains(url) }
    func evict(_ url: URL) throws {
        if failing.contains(url) { throw Fail() }
        evictedURLs.append(url)
    }
    func filesUnder(_ dir: URL) -> [URL] { tree[dir] ?? [] }
}

final class EvictEngineTests: XCTestCase {
    let folder = URL(fileURLWithPath: "/iCloud/Archive", isDirectory: true)
    let fileA = URL(fileURLWithPath: "/iCloud/Archive/a.pdf")
    let fileB = URL(fileURLWithPath: "/iCloud/Archive/b.pdf")
    let local = URL(fileURLWithPath: "/Users/rish/NotCloud")

    func makeEngine(_ ops: MockFileOps) -> EvictEngine { EvictEngine(ops: ops) }

    func test_nonICloudItemIsReportedNotUbiquitous() {
        let ops = MockFileOps()
        let summary = makeEngine(ops).evict(urls: [local])
        XCTAssertEqual(summary.notUbiquitous, ["NotCloud"])
        XCTAssertEqual(summary.evicted, 0)
        XCTAssertTrue(ops.evictedURLs.isEmpty)
    }

    func test_evictsUbiquitousFileDirectly() {
        let ops = MockFileOps()
        ops.ubiquitous = [fileA]
        let summary = makeEngine(ops).evict(urls: [fileA])
        XCTAssertEqual(summary.evicted, 1)
        XCTAssertEqual(ops.evictedURLs, [fileA])
    }

    func test_skipsAlreadyDatalessItem() {
        let ops = MockFileOps()
        ops.ubiquitous = [fileA]
        ops.dataless = [fileA]
        let summary = makeEngine(ops).evict(urls: [fileA])
        XCTAssertEqual(summary.skipped, 1)
        XCTAssertEqual(summary.evicted, 0)
    }

    func test_folderFailureFallsBackToPerFileWalk() {
        let ops = MockFileOps()
        ops.ubiquitous = [folder]
        ops.directories = [folder]
        ops.failing = [folder]
        ops.tree = [folder: [fileA, fileB]]
        ops.dataless = [fileB]
        let summary = makeEngine(ops).evict(urls: [folder])
        XCTAssertEqual(summary.evicted, 1)   // fileA
        XCTAssertEqual(summary.skipped, 1)   // fileB already dataless
        XCTAssertEqual(summary.failed, 0)    // folder failure absorbed by fallback
        XCTAssertEqual(ops.evictedURLs, [fileA])
    }

    func test_fileFailureRecordsFirstError() {
        let ops = MockFileOps()
        ops.ubiquitous = [fileA, fileB]
        ops.failing = [fileA, fileB]
        let summary = makeEngine(ops).evict(urls: [fileA, fileB])
        XCTAssertEqual(summary.failed, 2)
        XCTAssertEqual(summary.firstError, "simulated eviction failure")
    }

    func test_folderFailureWithEmptyWalkReportsFailure() {
        let ops = MockFileOps()
        ops.ubiquitous = [folder]
        ops.directories = [folder]
        ops.failing = [folder]
        let summary = makeEngine(ops).evict(urls: [folder])
        XCTAssertEqual(summary.failed, 1)
        XCTAssertEqual(summary.evicted, 0)
        XCTAssertEqual(summary.firstError, "simulated eviction failure")
    }
}
