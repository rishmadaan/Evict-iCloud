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
