import SwiftUI

@main
struct SwiftyCropDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .defaultSize(width: 700, height: 800)
        #endif
    }
}
