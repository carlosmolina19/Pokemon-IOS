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
            .mapError { $0 as Error }
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
