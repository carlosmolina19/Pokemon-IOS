import CoreData
import Foundation

extension PokemonAbility {
    
    // MARK: - Initialization

    convenience init(model: PokemonAbilityModel, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        name = model.name
        slot = Int16(model.slot)
    }
}
