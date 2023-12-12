import Foundation

final class PokemonSceneBuilder {
    
    func build() -> PokemonListView<PokemonListViewModelImpl> {
        let networkProvider = NetworkProviderImpl(session: .shared)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let remotePokemonRepository = RemotePokemonRepositoryImpl(networkProvider: networkProvider,
                                                                        decoder: decoder)
        
        let remotePokemonSpecieRepository = RemotePokemonSpecieRepositoryImpl(networkProvider: networkProvider,
                                                                              decoder: decoder)
        
        let fetchDetailUseCase = FetchPokemonDetailUseCaseImpl(remotePokemonRepository: remotePokemonRepository,
                                                               remotePokemonSpeciesRepository: remotePokemonSpecieRepository)
        
        let fetchPokemonPageUseCase = FetchPokemonPageUseCaseImpl(pokemonDetailUseCase: fetchDetailUseCase)
        let pokemonItemViewModelFactory = PokemonItemViewModelFactoryImpl()
        let viewModel = PokemonListViewModelImpl(fetchPokemonPageUseCase: fetchPokemonPageUseCase,
                                                 pokemonItemViewModelFactory: pokemonItemViewModelFactory)
        
        return PokemonListView(viewModel: viewModel)
    }
}
