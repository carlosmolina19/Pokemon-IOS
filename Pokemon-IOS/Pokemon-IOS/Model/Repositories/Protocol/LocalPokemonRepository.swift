import Combine
import Foundation

protocol LocalPokemonRepository {

    func fetch(number: Int) -> AnyPublisher<Pokemon, PokemonError>
    func save(from model: PokemonModel) -> AnyPublisher<Pokemon, PokemonError>
}
