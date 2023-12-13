import Combine
import Foundation

protocol SavePokemonDetailUseCase {
    func execute(model: PokemonModel) -> AnyPublisher<PokemonModel, PokemonError>
}
