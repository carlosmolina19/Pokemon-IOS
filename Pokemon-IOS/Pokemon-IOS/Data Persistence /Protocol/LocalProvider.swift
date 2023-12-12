import Combine
import CoreData
import Foundation

protocol LocalProvider {
    var context: NSManagedObjectContext { get }
    
    func fetch<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], Error>
    func save() -> AnyPublisher<Void, Error>
}
