import Combine
import Foundation

protocol FetchLocalPokemonDetailUseCase {
    func execute(number: Int) -> AnyPublisher<PokemonModel, PokemonError>
}
