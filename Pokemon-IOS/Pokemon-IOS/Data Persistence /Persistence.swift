import CoreData

final class Persistence {
    static let shared = Persistence()

    let persistentContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "Pokemon_IOS")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}
