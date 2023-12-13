import Combine
import Foundation

final class LocalPokemonRepositoryImpl: LocalPokemonRepository {
    
    // MARK: - Private Properties
    
    private let localProvider: LocalProvider
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(localProvider: LocalProvider) {
        self.localProvider = localProvider
    }
    
    // MARK: - Internal Methods
    
    func fetch(number: Int) -> AnyPublisher<Pokemon, PokemonError> {
        let predicate = NSPredicate(format: "id == %@", String(number))
        return localProvider.fetch(entityType: Pokemon.self, predicate: predicate)
            .tryMap { results in
                guard let firstPokemon = results.first else {
                    throw PokemonError.notFound
                }
                return firstPokemon
            }
            .mapError { error in
                (error as? PokemonError) ?? .genericError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func save(from model: PokemonModel) -> AnyPublisher<Pokemon, PokemonError> {
        return Future<Pokemon, PokemonError> {[weak self] promise in
            guard let self
            else {
                promise(.failure(PokemonError.deallocated))
                return
            }
            self.localProvider.context.perform {
                let pokemonEntity = Pokemon(model: model,
                                context: self.localProvider.context)
                
                self.localProvider.save()
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            promise(.failure(PokemonError.genericError(error)))
                        case .finished:
                            break
                        }
                    }, receiveValue: {
                        promise(.success(pokemonEntity))
                    })
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
}
