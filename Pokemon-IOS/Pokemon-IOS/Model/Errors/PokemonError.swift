import Foundation

enum PokemonError: Error {
    case invalidFormat
    case deallocated
    case genericError(Error)
}
