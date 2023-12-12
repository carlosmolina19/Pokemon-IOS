import Foundation

final class PokemonListViewModelPreview: PokemonListViewModel {
    
    var title: String {
        "Pokédex"
    }
    
    var description: String {
        "Use the advanced search to find Pokémon by type, weakness, ability and more!"
    }
    
    
    // MARK: - Internal Properties
    
    var items: [PokemonItemViewModel] = [PokemonItemViewModelPreview(),
                                         PokemonItemViewModelPreview(),
                                         PokemonItemViewModelPreview(),
                                         PokemonItemViewModelPreview()]
    
    // MARK: - Internal Methods
    
    func loadItems() {}
}
