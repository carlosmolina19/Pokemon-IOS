import SwiftUI

final class PokemonItemViewModelPreview: PokemonItemViewModel {
    
    // MARK: - Internal Computed Properties
    
    var number: String {
        "#0001"
    }
    
    var name: String {
        "Bulbasaur"
    }
    
    var abilities: [String] {
        ["Overgrow", "Chlorophyll"]
    }
    
    var types: [String] {
        ["Grass", "Poison"]
    }
    
    var backgroundColor: Color {
        Color("green")
    }
    
    var url: URL {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!

    }
}
