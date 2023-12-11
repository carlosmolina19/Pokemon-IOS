import Combine
import Foundation

final class FetchPokemonPageUseCaseImpl: FetchPokemonPageUseCase {
    
    // MARK: - Private Properties
    
    private let pokemonDetailUseCase: FetchPokemonDetailUseCase
    private var shouldStop = false
    
    // MARK: - Initialization
    
    init(pokemonDetailUseCase: FetchPokemonDetailUseCase) {
        self.pokemonDetailUseCase = pokemonDetailUseCase
    }
    
    // MARK: - Internal Methods
    
    func execute(page: Int) -> AnyPublisher<[PokemonModel], PokemonError> {
        let pageSize = 20
        let start = (page - 1) * pageSize + 1
        let end = start + pageSize - 1

        return (start...end).publisher
            .flatMap(maxPublishers: .max(1)) { number in
                self.pokemonDetailUseCase.execute(number: number)
                    .catch { error -> AnyPublisher<PokemonModel, PokemonError> in
                        guard case .notFound = error else {
                            return Fail(error: error).eraseToAnyPublisher()
                        }
                        return Empty(completeImmediately: true).setFailureType(to: PokemonError.self).eraseToAnyPublisher()
                    }
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
