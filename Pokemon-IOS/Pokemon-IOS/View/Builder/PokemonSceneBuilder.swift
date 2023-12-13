import CoreData
import Foundation

final class PokemonSceneBuilder {
    
    func build(persistentContainer: NSPersistentContainer) -> PokemonListView<PokemonListViewModelImpl> {
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: configuration)
        
        let networkProvider = NetworkProviderImpl(session: session)
        let localProvider = CoreDataProviderImpl(persistentContainer: persistentContainer)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let remotePokemonRepository = RemotePokemonRepositoryImpl(networkProvider: networkProvider,
                                                                  decoder: decoder)
        
        let remotePokemonSpecieRepository = RemotePokemonSpecieRepositoryImpl(networkProvider: networkProvider,
                                                                              decoder: decoder)
        
        let localPokemonRepository = LocalPokemonRepositoryImpl(localProvider: localProvider)
        
        let fetchDetailUseCase = FetchPokemonDetailUseCaseImpl(remotePokemonRepository: remotePokemonRepository,
                                                               remotePokemonSpeciesRepository: remotePokemonSpecieRepository)
        
        let fetchLocalPokemonUseCase = FetchLocalPokemonDetailUseCaseImpl(localPokemonRepository: localPokemonRepository)
        
        let savePokemonUseCase = SavePokemonDetailUseCaseImpl(localPokemonRepository: localPokemonRepository)
        
        let fetchPokemonPageUseCase = FetchPokemonPageUseCaseImpl(pokemonDetailUseCase: fetchDetailUseCase,
                                                                  fetchLocalPokemonDetailUseCase: fetchLocalPokemonUseCase,
                                                                  savePokemonDetailUseCase: savePokemonUseCase)
        
        let pokemonItemViewModelFactory = PokemonItemViewModelFactoryImpl()
        let viewModel = PokemonListViewModelImpl(fetchPokemonPageUseCase: fetchPokemonPageUseCase,
                                                 pokemonItemViewModelFactory: pokemonItemViewModelFactory)
        
        return PokemonListView(viewModel: viewModel)
    }
}
