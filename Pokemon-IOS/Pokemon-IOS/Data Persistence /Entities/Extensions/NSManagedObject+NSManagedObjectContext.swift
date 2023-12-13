import CoreData
import Foundation

extension NSManagedObject {
    
    // MARK: - Initialization
    
    convenience init(with context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
