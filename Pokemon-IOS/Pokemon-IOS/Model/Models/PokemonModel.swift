import Foundation

struct PokemonModel: Identifiable {

    // MARK: - Internal Properties

    let id: UUID
    let name: String
    let number: Int
    let abilities: [PokemonAbilityModel]
    let color: PokemonColorModel?
    let types: [PokemonTypeModel]
    let url: URL
}
