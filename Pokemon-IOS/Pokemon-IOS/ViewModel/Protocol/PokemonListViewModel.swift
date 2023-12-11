import Foundation

protocol PokemonListViewModel: ObservableObject {
    var items: [any PokemonItemViewModel] { get }
    var title: String { get }
    var description: String { get }
    func loadItems()
}
