import CoreData
import Foundation

extension PokemonAbility {
    
    // MARK: - Initialization

    convenience init(pokemonAbilityDto: PokemonResponseDto.PokemonAbilityDto,
                     context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        name = pokemonAbilityDto.ability.name
        slot = Int16(pokemonAbilityDto.slot)
    }
}
