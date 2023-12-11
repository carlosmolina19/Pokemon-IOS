import Combine
import Foundation

protocol FetchPokemonDetailUseCase {
    func execute(number: Int) -> AnyPublisher<PokemonModel, PokemonError>
}
