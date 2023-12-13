import Combine
import Foundation

final class FetchPokemonPageUseCaseImpl: FetchPokemonPageUseCase {
    
    // MARK: - Private Properties
    
    private let pokemonDetailUseCase: FetchPokemonDetailUseCase
    private let fetchLocalPokemonDetailUseCase: FetchLocalPokemonDetailUseCase
    private let savePokemonDetailUseCase: SavePokemonDetailUseCase
    
    private var shouldStop = false
    
    // MARK: - Initialization
    
    init(pokemonDetailUseCase: FetchPokemonDetailUseCase,
         fetchLocalPokemonDetailUseCase: FetchLocalPokemonDetailUseCase,
         savePokemonDetailUseCase: SavePokemonDetailUseCase) {
        
        self.pokemonDetailUseCase = pokemonDetailUseCase
        self.fetchLocalPokemonDetailUseCase = fetchLocalPokemonDetailUseCase
        self.savePokemonDetailUseCase = savePokemonDetailUseCase
        
    }
    
    // MARK: - Internal Methods
    
    func execute(page: Int) -> AnyPublisher<[PokemonModel], PokemonError> {
        let pageSize = 20
        let start = (page - 1) * pageSize + 1
        let end = start + pageSize - 1
        
        return (start...end).publisher
            .flatMap(maxPublishers: .max(5)) { number in
                self.pokemonDetailUseCase.execute(number: number)
                    .flatMap {
                        self.savePokemonDetailUseCase.execute(model: $0)
                    }
                    .catch { error -> AnyPublisher<PokemonModel, PokemonError> in
                        guard case .notFound = error else {
                            return  self.fetchLocalPokemonDetailUseCase.execute(number: number)
                        }
                        return Fail(error: error).eraseToAnyPublisher()
                    }
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
