import Combine
import CoreData
import Foundation

protocol LocalProvider {
    func fetch<T: NSManagedObject>(entityType: T.Type,
                                   predicate: NSPredicate) -> AnyPublisher<[T], Error>
    
    func save() -> AnyPublisher<Void, Error>
    func create<T: NSManagedObject>(ofType entityType: T.Type) -> T
}
