import Combine
import Foundation

final class NetworkProviderImpl: NetworkProvider {
    
    // MARK: - Private Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Internal Methods
    
    func fetch(from url: URL) -> AnyPublisher<Data, Error> {
        return session.dataTaskPublisher(for: url)
            .retry(3)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                switch httpResponse.statusCode {
                case 200...299:
                    return output.data
                case 404:
                    throw NSError(domain: "pokemon.network", code: 404)
                default:
                    throw URLError(.badServerResponse)
                }
            }
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
