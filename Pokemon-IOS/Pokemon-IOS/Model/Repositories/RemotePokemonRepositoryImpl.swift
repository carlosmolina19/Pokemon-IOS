import Combine
import Foundation

final class RemotePokemonRepositoryImpl: RemotePokemonRepository {

    // MARK: - Private Properties

    private let networkProvider: NetworkProvider
    private let decoder: JSONDecoder

    // MARK: - Initialization

    init(networkProvider: NetworkProvider, decoder: JSONDecoder) {
        self.networkProvider = networkProvider
        self.decoder = decoder
    }

    // MARK: - Internal Methods

    func fetch(number: Int) -> AnyPublisher<PokemonResponseDto, PokemonError> {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(number)/")
        else {
            fatalError("Can't initialize URL")
        }
        return networkProvider.fetch(from: url).tryMap { [weak self] data in
            guard let self,
                  let dto = try? self.decoder.decode(PokemonResponseDto.self, 
                                                     from: data)
            else {
                throw PokemonError.invalidFormat
            }
            return dto
            
        }.mapError {
            guard let error = $0 as? PokemonError
            else {
                return PokemonError.genericError($0)
            }
            return error
        }
        .eraseToAnyPublisher()
    }
}
