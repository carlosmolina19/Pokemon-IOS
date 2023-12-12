import SwiftUI

@main
struct Pokemon_IOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            PokemonSceneBuilder().build()
        }
    }
}
