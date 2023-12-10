import Combine
import Foundation

protocol NetworkProvider {
    func fetch(from url: URL) -> AnyPublisher<Data, Error>
}
