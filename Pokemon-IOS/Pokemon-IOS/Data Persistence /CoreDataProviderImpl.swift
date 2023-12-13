import Combine
import CoreData
import Foundation

final class CoreDataProviderImpl: LocalProvider {

        
    // MARK: - Private Properties

    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
     
    // MARK: - Initialization

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Internal Methods

    func fetch<T: NSManagedObject>(entityType: T.Type,
                                    predicate: NSPredicate) -> AnyPublisher<[T], Error> {
        
        Future<[T], Error> { [weak self] promise in
            guard let self
            else {
                return
            }
            
            context.perform {
                do {
                    let fetchRequest = T.fetchRequest()
                    fetchRequest.predicate = predicate
                    
                    let result = try self.context.fetch(fetchRequest)
                    
                    guard let typedResult = result as? [T] 
                    else {
                        throw NSError(domain: "pokemon.local", code: 404)
                    }
                    promise(.success(typedResult))
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
    
    func create<T: NSManagedObject>(ofType entityType: T.Type) -> T {
        let name = String(describing: entityType)
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        return T(entity: entity, insertInto: context)
    }
}
