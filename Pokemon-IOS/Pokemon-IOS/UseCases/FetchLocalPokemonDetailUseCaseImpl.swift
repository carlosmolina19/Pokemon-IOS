import Combine
import Foundation

final class FetchLocalPokemonDetailUseCaseImpl: FetchLocalPokemonDetailUseCase {
    
    // MARK: - Private Properties
    
    private let localPokemonRepository: LocalPokemonRepository
    
    // MARK: - Initialization
    
    init(localPokemonRepository: LocalPokemonRepository) {
        
        self.localPokemonRepository = localPokemonRepository
    }
    
    // MARK: - Internal Methods
    
    func execute(number: Int) -> AnyPublisher<PokemonModel, PokemonError> {
        localPokemonRepository.fetch(number: number).tryMap {
            guard let model = PokemonModel(managedObject: $0)
            else {
                throw PokemonError.notFound
            }
            return model
        }
        .mapError { error in
            (error as? PokemonError) ?? .genericError(error)
        }
        .eraseToAnyPublisher()
    }
}
