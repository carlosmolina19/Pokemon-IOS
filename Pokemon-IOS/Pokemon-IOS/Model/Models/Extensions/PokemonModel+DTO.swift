import Foundation

extension PokemonModel {

    // MARK: - Initialization

    init(dto: PokemonResponseDto, 
         speciesDto: PokemonSpeciesResponseDto?) {
        
        self.id = UUID()
        self.name = dto.name
        self.number = dto.id
        self.url = dto.sprites.frontDefault
        self.abilities = dto.abilities.map { PokemonAbilityModel(dto: $0) }
        self.types = dto.types.map { PokemonTypeModel(dto: $0) }
        
        guard let speciesDto 
        else {
            self.color = nil
            return
        }
        
        self.color = PokemonColorModel(dto: speciesDto.color)
    }
}
