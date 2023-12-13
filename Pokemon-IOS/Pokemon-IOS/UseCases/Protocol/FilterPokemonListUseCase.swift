import Foundation

protocol FilterPokemonListUseCase {
    func execute(text: String, pokemons: [PokemonModel]) -> [PokemonModel]
}
