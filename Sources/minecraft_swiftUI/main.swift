import SwiftUI

@main
struct minecraft_swiftUI: App {
    @StateObject private var playerInput = PlayerInput()

    var body: some Scene {
        WindowsGroup {
            ContentView()
                .environmentObject(playerInput)
        }
    }
}