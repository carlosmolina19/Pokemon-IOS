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
        return self.fetch(number: model.number)
            .catch { [weak self] _ in
                guard let self else {
                    return Fail<Pokemon, PokemonError>(error: PokemonError.deallocated).eraseToAnyPublisher()
                }
                
                return self.update(entity: self.localProvider.create(ofType: Pokemon.self),
                                   with: model)
            }
            .flatMap { entity in
                self.update(entity: entity,
                                   with: model)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func update(entity: Pokemon, with model: PokemonModel) -> AnyPublisher<Pokemon, PokemonError> {
        entity.id = Int16(model.number)
        entity.name = model.name
        entity.url = model.url.absoluteString
        
        entity.abilities = NSSet(array: model.abilities.map {
            let ability = self.localProvider.create(ofType: PokemonAbility.self)
            ability.name = $0.name
            return ability
        })
        
        entity.types = NSSet(array: model.types.map {
            let type = self.localProvider.create(ofType: PokemonType.self)
            type.name = $0.name
            return type
        })
        entity.color = model.color?.name ?? ""
        
        return self.localProvider.save()
            .map { _ in entity }
            .mapError { error in
                (error as? PokemonError) ?? .genericError(error)
            }
            .eraseToAnyPublisher()
    }
}
