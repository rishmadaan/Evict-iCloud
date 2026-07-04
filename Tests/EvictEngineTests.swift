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
}
