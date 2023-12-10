import Combine
import Foundation

protocol RemotePokemonRepository {

    func fetch(number: Int) -> AnyPublisher<PokemonResponseDto, PokemonError>
}
