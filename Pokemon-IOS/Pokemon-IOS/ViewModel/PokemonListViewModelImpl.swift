import Combine
import Foundation

final class PokemonListViewModelImpl: PokemonListViewModel {
    
    // MARK: - Internal Computed Properties
    
    var title: String {
        "Pokédex"
    }
    
    var description: String {
        "Use the advanced search to find Pokémon by type, weakness, ability and more!"
    }
    
    var promptSearch: String {
        "Search a pokémon"
    }
    
    // MARK: - Internal Properties
    
    @Published var items = [any PokemonItemViewModel]()
    @Published var isLoading: Bool = false
    @Published var filterText = "" {
        didSet {
            self.isLoading = filterText.isEmpty ? false : true
            pokemonsFiltered = filterPokemonListUseCase.execute(text: filterText,
                                                             pokemons: pokemonsModel)
        }
    }
    
    // MARK: - Private Properties
    
    private var fetchPokemonPageUseCase: FetchPokemonPageUseCase
    private var pokemonItemViewModelFactory: PokemonItemViewModelFactory
    private var filterPokemonListUseCase: FilterPokemonListUseCase
    private var cancellables = Set<AnyCancellable>()
    private var page: Int = 0
    private var pokemonsModel: [PokemonModel] = []
    private var pokemonsFiltered: [PokemonModel] = [] {
        didSet {
            items = pokemonsFiltered
            .map { self.pokemonItemViewModelFactory.createPokemonItemViewModel(from: $0) }
        }
    }
    
    // MARK: - Initialization
    
    init(fetchPokemonPageUseCase: FetchPokemonPageUseCase,
         filterPokemonListUseCase: FilterPokemonListUseCase,
         pokemonItemViewModelFactory: PokemonItemViewModelFactory) {
        
        self.fetchPokemonPageUseCase = fetchPokemonPageUseCase
        self.pokemonItemViewModelFactory = pokemonItemViewModelFactory
        self.filterPokemonListUseCase = filterPokemonListUseCase
    }
    
    // MARK: - Internal Methods
    
    func loadItems() {
        isLoading = true
        page += 1
        fetchPokemonPageUseCase.execute(page: page)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self
                    else {
                        return
                    }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                    self.isLoading = false
                },
                receiveValue: { [weak self] newItems in
                    guard let self
                    else {
                        return
                    }
                    self.pokemonsModel.append(contentsOf: newItems)
                    self.pokemonsFiltered = self.pokemonsModel
                }
            )
            .store(in: &cancellables)
    }
}
