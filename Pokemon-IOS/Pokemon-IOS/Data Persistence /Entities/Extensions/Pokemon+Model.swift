import CoreData
import Foundation

extension Pokemon {
    
    // MARK: - Initialization
    
    convenience init(model: PokemonModel, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        id = Int16(model.number)
        name = model.name
        color = model.color?.name
        url = model.url.absoluteString
        abilities = NSSet(array: model.abilities
            .map { 
                PokemonAbility(model: $0, context: context)
            })
        
        types = NSSet(array: model.types
            .map {
                PokemonType(model: $0, context: context)
            })
        
    }
}
