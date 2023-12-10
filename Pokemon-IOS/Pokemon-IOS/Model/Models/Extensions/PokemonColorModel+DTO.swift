import Foundation

extension PokemonColorModel {

    // MARK: - Initialization

    init(dto: PokemonSpeciesResponseDto.PokemonColorDto) {
        self.id = UUID()
        self.name = dto.name
    }
}
