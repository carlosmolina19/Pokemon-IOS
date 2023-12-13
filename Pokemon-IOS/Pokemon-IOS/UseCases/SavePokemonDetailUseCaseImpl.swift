import Combine
import Foundation

final class SavePokemonDetailUseCaseImpl: SavePokemonDetailUseCase {
    
    // MARK: - Private Properties
    
    private let localPokemonRepository: LocalPokemonRepository
    
    // MARK: - Initialization
    
    init(localPokemonRepository: LocalPokemonRepository) {
        
        self.localPokemonRepository = localPokemonRepository
    }
    
    // MARK: - Internal Methods
    
    func execute(model: PokemonModel) -> AnyPublisher<PokemonModel, PokemonError> {
        localPokemonRepository.save(from: model)
            .map {_ in model }
            .eraseToAnyPublisher()
    }
}
