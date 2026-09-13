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

public struct RealFileOps: FileOps {
    public init() {}

    public func isUbiquitous(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isUbiquitousItemKey]))?.isUbiquitousItem ?? false
    }

    public func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }

    public func isDataless(_ url: URL) -> Bool {
        let values = try? url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        return values?.ubiquitousItemDownloadingStatus == .notDownloaded
    }

    public func evict(_ url: URL) throws {
        try FileManager.default.evictUbiquitousItem(at: url)
    }

    public func filesUnder(_ dir: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: dir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return enumerator.compactMap { $0 as? URL }.filter { !isDirectory($0) }
    }
}
