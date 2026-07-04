import Foundation

public struct EvictSummary: Equatable {
    public var evicted = 0
    public var skipped = 0
    public var failed = 0
    public var notUbiquitous: [String] = []
    public var firstError: String?
    public init() {}
}

public protocol FileOps {
    func isUbiquitous(_ url: URL) -> Bool
    func isDirectory(_ url: URL) -> Bool
    func isDataless(_ url: URL) -> Bool
    func evict(_ url: URL) throws
    func filesUnder(_ dir: URL) -> [URL]
}

public struct EvictEngine {
    private let ops: FileOps
    public init(ops: FileOps) { self.ops = ops }

    public func evict(urls: [URL]) -> EvictSummary {
        var summary = EvictSummary()
        for url in urls {
            guard ops.isUbiquitous(url) else {
                summary.notUbiquitous.append(url.lastPathComponent)
                continue
            }
            if ops.isDataless(url) {
                summary.skipped += 1
                continue
            }
            do {
                try ops.evict(url)
                summary.evicted += 1
            } catch {
                if ops.isDirectory(url) {
                    evictContents(of: url, into: &summary)
                } else {
                    record(error, into: &summary)
                }
            }
        }
        return summary
    }

    private func evictContents(of dir: URL, into summary: inout EvictSummary) {
        for file in ops.filesUnder(dir) {
            if ops.isDataless(file) {
                summary.skipped += 1
                continue
            }
            do {
                try ops.evict(file)
                summary.evicted += 1
            } catch {
                record(error, into: &summary)
            }
        }
    }

    private func record(_ error: Error, into summary: inout EvictSummary) {
        summary.failed += 1
        if summary.firstError == nil { summary.firstError = error.localizedDescription }
    }
}
