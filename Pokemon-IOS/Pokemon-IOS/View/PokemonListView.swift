import SwiftUI

struct PokemonListView<T: PokemonListViewModel>: View {
    
    // MARK: - Private Properties
    
    @ObservedObject private var viewModel: T
    private let columns = [
        GridItem(.flexible(minimum: 180), spacing: 16),
        GridItem(.flexible(minimum: 180))
    ]

    // MARK: - Initialization

    init(viewModel: T) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    Text(viewModel.description)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                   
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.items.indices, id: \.self) { index in
                                PokemonItemView(viewModel: viewModel.items[index])
                                    .onAppear {
                                        if index == viewModel.items.count - 5 {
                                            viewModel.loadItems()
                                        }
                                    }
                            }
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle(viewModel.title).font(.title)
            .navigationBarTitleDisplayMode(.large)
        }.onAppear(perform: {
            viewModel.loadItems()
        })
    }


}

// MARK: - Preview

#Preview {
    PokemonListView(viewModel: PokemonListViewModelPreview())
}
