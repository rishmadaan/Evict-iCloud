import SwiftUI

@main
struct EvictiCloudApp: App {
    var body: some Scene {
        Window("Evict iCloud", id: "main") {
            Text("Evict iCloud").padding(40)
        }
        .windowResizability(.contentSize)
    }
}
