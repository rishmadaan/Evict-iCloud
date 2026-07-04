import Foundation
import UniformTypeIdentifiers
import UserNotifications

final class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        Task {
            let urls = await Self.fileURLs(from: context)
            let accessed = urls.filter { $0.startAccessingSecurityScopedResource() }
            let summary = EvictEngine(ops: RealFileOps()).evict(urls: urls)
            accessed.forEach { $0.stopAccessingSecurityScopedResource() }
            await Self.notify(summary: summary, items: urls)
            context.completeRequest(returningItems: nil)
        }
    }

    static func fileURLs(from context: NSExtensionContext) async -> [URL] {
        let providers = (context.inputItems as? [NSExtensionItem])?
            .flatMap { $0.attachments ?? [] } ?? []
        var urls: [URL] = []
        for provider in providers
        where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            guard let item = try? await provider.loadItem(
                forTypeIdentifier: UTType.fileURL.identifier
            ) else { continue }
            if let url = item as? URL {
                urls.append(url)
            } else if let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) {
                urls.append(url)
            }
        }
        return urls
    }

    static func notify(summary: EvictSummary, items: [URL]) async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert])
        let (title, body) = EvictReport.message(for: summary, items: items)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil)
        try? await center.add(request)
    }
}
