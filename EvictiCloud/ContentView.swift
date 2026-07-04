import SwiftUI

struct ContentView: View {
    @State private var isTargeted = false
    @State private var lastResult = ""

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 36))
                .foregroundStyle(.tint)

            Text("Right-click any iCloud Drive file or folder,\nthen Quick Actions → \u{201C}Evict from iCloud\u{201D}.")
                .multilineTextAlignment(.center)

            dropZone

            if !lastResult.isEmpty {
                Text(lastResult)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("If the Quick Action doesn\u{2019}t appear, enable \u{201C}Evict from iCloud\u{201D} in Extension Settings.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Open Extension Settings\u{2026}", action: openExtensionSettings)
        }
        .padding(24)
        .frame(width: 380)
    }

    private var dropZone: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            .foregroundStyle(isTargeted ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            .frame(height: 110)
            .overlay(Text("Drop files or folders here to evict").foregroundStyle(.secondary))
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

    private func openExtensionSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.ExtensionsPreferences",
            "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
        ]
        for candidate in candidates {
            if let url = URL(string: candidate), NSWorkspace.shared.open(url) { return }
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
    }
}
