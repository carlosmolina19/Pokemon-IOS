import Foundation

struct PokemonResponseDto: Decodable {
    let name: String
    let id: Int
    let abilities: [PokemonAbilityDto]
    let sprites: PokemonSpritesDto
    let types: [PokemonTypeDto]
    let species: PokemonSpeciesDto
    
    struct PokemonAbilityDto: Decodable {
        struct Ability: Codable {
            let name: String
            let url: String
        }

        let ability: Ability
        let slot: Int
    }

    struct PokemonTypeDto: Decodable {
        struct TypeDetails: Decodable {
            let name: String
            let url: String
        }

        let slot: Int
        let type: TypeDetails

    }

    struct PokemonSpritesDto: Decodable {
        let frontDefault: URL
    }
    
    struct PokemonSpeciesDto: Decodable {
        let name: String
        let url: URL
    }
}
