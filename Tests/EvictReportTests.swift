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
