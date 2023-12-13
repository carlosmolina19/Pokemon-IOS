import Combine
import Foundation

final class FetchPokemonDetailUseCaseImpl: FetchPokemonDetailUseCase {
    
    // MARK: - Private Properties
    
    private let remotePokemonRepository: RemotePokemonRepository
    private let remotePokemonSpeciesRepository: RemotePokemonSpecieRepository
    
    // MARK: - Initialization
    
    init(remotePokemonRepository: RemotePokemonRepository,
         remotePokemonSpeciesRepository: RemotePokemonSpecieRepository) {
        
        self.remotePokemonRepository = remotePokemonRepository
        self.remotePokemonSpeciesRepository = remotePokemonSpeciesRepository
    }
    
    // MARK: - Internal Methods
    
    func execute(number: Int) -> AnyPublisher<PokemonModel, PokemonError> {
        remotePokemonRepository.fetch(number: number)
            .flatMap { [weak self] dto in
                guard let self
                else {
                    return Fail<PokemonModel, PokemonError>(error: PokemonError.deallocated).eraseToAnyPublisher()
                    
                }
                return self.remotePokemonSpeciesRepository.fetch(number: Int(dto.species.url.pathComponents.last ?? "0") ?? 0)
                    .map { speciesDto in
                        PokemonModel(dto: dto, speciesDto: speciesDto)
                    }
                    .catch { _ in
                        Just(PokemonModel(dto: dto, speciesDto: nil))
                    }
                    .setFailureType(to: PokemonError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
