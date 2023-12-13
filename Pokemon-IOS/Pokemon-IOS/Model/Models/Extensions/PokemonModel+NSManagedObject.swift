import Foundation

extension PokemonModel {
    
    // MARK: - Initialization

    init?(managedObject: Pokemon) {
        guard let name = managedObject.name,
              let url = URL(string: managedObject.url ?? ""),
              let abilities = managedObject.abilities?.allObjects as? [PokemonAbility],
              let types = managedObject.types?.allObjects as? [PokemonType]
        else {
            return nil
        }
        
        self.id = UUID()
        self.name = name
        self.number = Int(managedObject.id)
        self.url = url
        self.abilities = abilities.map { PokemonAbilityModel(managedObject: $0) }
            .compactMap { $0 }
        
        self.types = types.map { PokemonTypeModel(managedObject: $0) }.compactMap { $0 }
        self.color = .init(id: UUID(), name: managedObject.color ?? "")
    }
}
