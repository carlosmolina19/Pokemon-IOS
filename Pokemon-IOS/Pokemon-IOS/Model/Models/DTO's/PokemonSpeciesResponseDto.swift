import Foundation

struct PokemonSpeciesResponseDto: Decodable {
    let color: PokemonColorDto
    
    struct PokemonColorDto: Decodable {
        let name: String
    }
}
