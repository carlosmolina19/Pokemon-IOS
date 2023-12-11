import Combine
import Foundation

protocol FetchPokemonPageUseCase {
    func execute(page: Int) -> AnyPublisher<[PokemonModel], PokemonError>
}
