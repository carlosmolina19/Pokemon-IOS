import Foundation

final class FilterPokemonListUseCaseImpl: FilterPokemonListUseCase {

    // MARK: - Internal Methods

    func execute(text: String, pokemons: [PokemonModel]) -> [PokemonModel] {
        guard !text.isEmpty
        else {
            return pokemons
        }

        return pokemons.filter {
            return $0.name.localizedCaseInsensitiveContains(text) || $0.abilities.contains {
                $0.name.localizedCaseInsensitiveContains(text)
            } || $0.types.contains {
                $0.name.localizedCaseInsensitiveContains(text)
            }
        }
        .sorted { $0.number < $1.number }
    }
}
