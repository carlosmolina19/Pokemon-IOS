import Combine
import Foundation

protocol LocalPokemonRepository {

    func fetch(pokemonId: Int) -> AnyPublisher<Pokemon, PokemonError>
    func save(from pokemonResponseDto: PokemonResponseDto,
              pokemonSpeciesResponseDto: PokemonSpeciesResponseDto?) -> AnyPublisher<Void, PokemonError>
}
