import SwiftUI

@main
struct EvictiCloudApp: App {
    var body: some Scene {
        Window("Evict iCloud", id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
