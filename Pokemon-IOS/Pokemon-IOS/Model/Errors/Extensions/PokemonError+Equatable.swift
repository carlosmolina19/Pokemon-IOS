import Foundation

extension PokemonError: Equatable {
    
    // MARK: - Equatable

    static func ==(lhs: PokemonError, rhs: PokemonError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidFormat, .invalidFormat), (.deallocated, .deallocated), (.notFound, .notFound):
            return true
        case (.genericError(let lhsError), .genericError(let rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        default:
            return false
        }
    }
}
