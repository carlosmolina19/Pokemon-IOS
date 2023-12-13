import Foundation

final class PokemonListViewModelPreview: PokemonListViewModel {
    
    var promptSearch: String {
        "Search a pokémon"
    }
    
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
    
    @Published var filterText: String = ""
    @Published var isLoading: Bool = false
    
    // MARK: - Internal Methods
    
    func loadItems() {}
}
