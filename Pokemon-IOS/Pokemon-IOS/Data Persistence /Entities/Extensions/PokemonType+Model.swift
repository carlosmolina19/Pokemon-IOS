import CoreData
import Foundation

extension PokemonType {
    
    // MARK: - Initialization

    convenience init(model: PokemonTypeModel, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        name = model.name
        slot = Int16(model.slot)
    }
}
