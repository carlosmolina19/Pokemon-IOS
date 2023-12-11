import Foundation

protocol PokemonItemViewModelFactory {
    func createPokemonItemViewModel(from model: PokemonModel) -> any PokemonItemViewModel
}
