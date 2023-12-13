import SwiftUI

@main
struct Pokemon_IOSApp: App {
    let persistence = Persistence.shared

    var body: some Scene {
        WindowGroup {
            PokemonSceneBuilder().build(persistentContainer: persistence.persistentContainer)
        }
    }
}
