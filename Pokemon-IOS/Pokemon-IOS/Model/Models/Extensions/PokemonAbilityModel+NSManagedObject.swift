import Foundation

extension PokemonAbilityModel {
    
    // MARK: - Initialization

    init?(managedObject: PokemonAbility) {
        guard let name = managedObject.name
        else {
            return nil
        }
        
        self.id = UUID()
        self.name = name
        self.slot = Int(managedObject.slot)
    }
}
