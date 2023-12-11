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
    
    // MARK: - Internal Properties
    
    @Published var items = [any PokemonItemViewModel]()
    
    // MARK: - Private Properties
    
    private var fetchPokemonPageUseCase: FetchPokemonPageUseCase
    private var pokemonItemViewModelFactory: PokemonItemViewModelFactory
    private var cancellables = Set<AnyCancellable>()
    private var page: Int = 0
    
    // MARK: - Initialization
    
    init(fetchPokemonPageUseCase: FetchPokemonPageUseCase,
         pokemonItemViewModelFactory: PokemonItemViewModelFactory) {
        
        self.fetchPokemonPageUseCase = fetchPokemonPageUseCase
        self.pokemonItemViewModelFactory = pokemonItemViewModelFactory
        
    }
    
    // MARK: - Internal Methods
    
    func loadItems() {
        page += 1
        fetchPokemonPageUseCase.execute(page: page)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                },
                receiveValue: { [weak self] newItems in
                    guard let self
                    else {
                        return
                    }
                    self.items.append(contentsOf: newItems.map { self.pokemonItemViewModelFactory.createPokemonItemViewModel(from: $0)
                    })
                }
            )
            .store(in: &cancellables)
    }
}
