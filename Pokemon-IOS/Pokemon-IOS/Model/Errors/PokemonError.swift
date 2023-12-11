import Foundation

enum PokemonError: Error {
    case invalidFormat
    case deallocated
    case notFound
    case genericError(Error)
}
