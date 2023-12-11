import Foundation

final class PokemonItemViewModelFactoryImpl: PokemonItemViewModelFactory {

    func createPokemonItemViewModel(from model: PokemonModel) -> PokemonItemViewModel {
        PokemonItemViewModelImpl(model: model)
    }
}
