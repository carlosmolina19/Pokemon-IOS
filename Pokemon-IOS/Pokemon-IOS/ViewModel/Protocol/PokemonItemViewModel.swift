import SwiftUI

protocol PokemonItemViewModel {
    var number: String { get}
    var name: String { get }
    var abilities: [String] { get }
    var types: [String] { get }
    var backgroundColor: Color { get }
    var url: URL { get }
}
