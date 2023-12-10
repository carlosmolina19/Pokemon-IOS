import Combine
import Foundation

protocol RemotePokemonSpecieRepository {

    func fetch(number: Int) -> AnyPublisher<PokemonSpeciesResponseDto, PokemonError>
}
