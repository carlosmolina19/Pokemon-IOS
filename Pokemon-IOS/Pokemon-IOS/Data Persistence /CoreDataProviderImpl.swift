import Combine
import CoreData
import Foundation

final class CoreDataProviderImpl: LocalProvider {
    
    // MARK: - Internal Properties
    
    let context: NSManagedObjectContext
        
    // MARK: - Private Properties

    private let persistentContainer: NSPersistentContainer
     
    // MARK: - Initialization

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Internal Methods

    func fetch<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], Error> {
        Future<[T], Error> { [weak self] promise in
            guard let self
            else {
                return
            }

            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
            fetchRequest.predicate = predicate

            context.perform {
                do {
                    let result = try self.context.fetch(fetchRequest)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func save() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self
            else {
                return
            }
            
            context.perform {
                do {
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
