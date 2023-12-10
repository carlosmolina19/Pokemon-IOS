import Foundation

extension PokemonTypeModel {

    // MARK: - Initialization

    init(dto: PokemonResponseDto.PokemonTypeDto) {
        self.id = UUID()
        self.name = dto.type.name
        self.slot = dto.slot
    }
}

