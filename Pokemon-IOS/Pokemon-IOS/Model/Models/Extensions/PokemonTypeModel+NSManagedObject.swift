import Foundation

extension PokemonTypeModel {
    
    // MARK: - Initialization

    init?(managedObject: PokemonType) {
        guard let name = managedObject.name
        else {
            return nil
        }
        
        self.id = UUID()
        self.name = name
        self.slot = Int(managedObject.slot)
    }
}
