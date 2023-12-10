import Foundation

extension PokemonAbilityModel {

    // MARK: - Initialization

    init(dto: PokemonResponseDto.PokemonAbilityDto) {
        self.id = UUID()
        self.name = dto.ability.name
        self.slot = dto.slot
    }
}
