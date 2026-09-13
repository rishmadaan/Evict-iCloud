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

import SwiftUI

struct ContentView: View {
    @State private var isTargeted = false
    @State private var lastResult = ""

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 36))
                .foregroundStyle(.tint)

            Text("Evict iCloud")
                .font(.title2.weight(.semibold))

            Text("Reclaim disk space by removing the local copies of\niCloud Drive files. They stay safe in iCloud and\nre-download when you open them \u{2014} nothing is deleted.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            dropZone

            if !lastResult.isEmpty {
                Text(lastResult)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(28)
        .frame(width: 380)
    }

    private var dropZone: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            .foregroundStyle(isTargeted ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            .frame(height: 120)
            .overlay(
                Text(isTargeted ? "Release to evict" : "Drop files or folders here")
                    .foregroundStyle(.secondary)
            )
            .dropDestination(for: URL.self) { urls, _ in
                evict(urls)
                return true
            } isTargeted: { isTargeted = $0 }
    }

    private func evict(_ urls: [URL]) {
        lastResult = "Evicting\u{2026}"
        Task.detached(priority: .userInitiated) {
            let accessed = urls.filter { $0.startAccessingSecurityScopedResource() }
            let summary = EvictEngine(ops: RealFileOps()).evict(urls: urls)
            accessed.forEach { $0.stopAccessingSecurityScopedResource() }
            let (title, body) = EvictReport.message(for: summary, items: urls)
            await MainActor.run { lastResult = "\(title) \u{2014} \(body)" }
        }
    }
}
