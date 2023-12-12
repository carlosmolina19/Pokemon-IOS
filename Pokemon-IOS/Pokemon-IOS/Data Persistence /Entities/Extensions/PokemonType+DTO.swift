import CoreData
import Foundation

extension PokemonType {
    
    // MARK: - Initialization

    convenience init(pokemonTypeDto: PokemonResponseDto.PokemonTypeDto,
                     context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        name = pokemonTypeDto.type.name
        slot = Int16(pokemonTypeDto.slot)
    }
}
