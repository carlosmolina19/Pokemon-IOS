import CoreData
import Foundation

extension Pokemon {
    
    // MARK: - Initialization
    
    convenience init(pokemonResponseDto: PokemonResponseDto,
                     pokemonSpeciesDto: PokemonSpeciesResponseDto?,
                     context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        id = Int16(pokemonResponseDto.id)
        name = pokemonResponseDto.name
        color = pokemonSpeciesDto?.color.name
        url = pokemonResponseDto.sprites.frontDefault.absoluteString
        abilities = NSSet(array: pokemonResponseDto.abilities
            .map { 
                PokemonAbility(pokemonAbilityDto: $0, context: context)
            })
        
        types = NSSet(array: pokemonResponseDto.types
            .map {
                PokemonType(pokemonTypeDto: $0, context: context)
            })
        
    }
}
