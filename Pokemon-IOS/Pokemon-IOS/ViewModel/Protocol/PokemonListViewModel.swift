import Foundation

protocol PokemonListViewModel: ObservableObject {
    var items: [any PokemonItemViewModel] { get }
    var title: String { get }
    var description: String { get }
    var promptSearch: String { get }
    var filterText: String { get set }
    var isLoading: Bool { get set  }

    func loadItems()
}
