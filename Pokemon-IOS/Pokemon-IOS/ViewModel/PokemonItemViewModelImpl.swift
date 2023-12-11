import SwiftUI

final class PokemonItemViewModelImpl: PokemonItemViewModel {
    
    // MARK: - Internal Computed Properties
    
    var name: String {
        model.name
    }
    
    var url: URL {
        model.url
    }
    
    var number: String {
        String(format: "#%04d", model.number)
    }
    
    var abilities: [String] {
        model.abilities.sorted { $0.slot <= $1.slot }.map { $0.name }
    }
    
    var types: [String] {
        model.types.sorted { $0.slot <= $1.slot }.map { $0.name }
    }
    
    var backgroundColor: Color {
        Color(model.color?.name ?? "white")
    }

    // MARK: - Private Properties
    
    private let model: PokemonModel

    // MARK: - Initialization

    init(model: PokemonModel) {
        self.model = model
    }
}
