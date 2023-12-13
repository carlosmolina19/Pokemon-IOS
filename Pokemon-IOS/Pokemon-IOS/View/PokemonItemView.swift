import NukeUI
import SwiftUI

struct PokemonItemView: View {
    
    // MARK: - Private Properties
    
    private let viewModel: PokemonItemViewModel
    
    // MARK: - Initialization
    
    init(viewModel: PokemonItemViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.bottom, 16)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    ForEach(viewModel.types, id: \.self) { type in
                        Text(type)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color("backgroundAbilityColor"))
                            .cornerRadius(8)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            
            VStack(alignment: .trailing) {
                Text(viewModel.number)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.trailing, 8)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                
                ZStack(alignment: .bottom) {
                    Image("pokeBallBackground")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .opacity(0.2)
                        .offset(x: 10, y: 10)
                        .clipped()
                    
                    LazyImage(url: viewModel.url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            
        }
        .padding(.top, 8)
        .padding(.leading, 8)
        .background(viewModel.backgroundColor)
        .cornerRadius(12)
        .shadow(color: .gray, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    PokemonItemView(viewModel: PokemonItemViewModelPreview())
}
