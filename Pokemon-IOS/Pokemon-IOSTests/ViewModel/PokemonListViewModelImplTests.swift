import Combine
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class PokemonListViewModelImplTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonListViewModelImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var mockFetchPokemonPageUseCase: FetchPokemonPageUseCaseMock!
    private var mockPokemonItemViewModelFactory: PokemonItemViewModelFactoryMock!
    private var mockPokemonItemViewModel: PokemonItemViewModelMock!
    private var decoder: JSONDecoder!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockFetchPokemonPageUseCase = mock(FetchPokemonPageUseCase.self)
        mockPokemonItemViewModelFactory = mock(PokemonItemViewModelFactory.self)
        mockPokemonItemViewModel = mock(PokemonItemViewModel.self)
        
        sut = SUT(fetchPokemonPageUseCase: mockFetchPokemonPageUseCase,
                  pokemonItemViewModelFactory: mockPokemonItemViewModelFactory)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockFetchPokemonPageUseCase = nil
        mockPokemonItemViewModelFactory = nil
        mockPokemonItemViewModel = nil
        decoder = nil
        
    }
    
    // MARK: - Tests
    
    func test_init_shouldReturnValues() throws {
        sut = SUT(fetchPokemonPageUseCase: mockFetchPokemonPageUseCase,
                  pokemonItemViewModelFactory: mockPokemonItemViewModelFactory)
    
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.title, "Pokédex")
        XCTAssertEqual(sut.description,
                       "Use the advanced search to find Pokémon by type, weakness, ability and more!")
    }
    
    func test_loadItems_shouldReturnValues() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let pokemonModel = PokemonModel(dto: pokemonResponseDto,
                                        speciesDto: nil)
        
        let expectation = XCTestExpectation(description: "loadItems")
        
        let publisherFetch = Just([pokemonModel])
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
        
        
        given(mockFetchPokemonPageUseCase.execute(page: 1)).willReturn(publisherFetch)
        given(mockPokemonItemViewModelFactory.createPokemonItemViewModel(from: any())).willReturn(mockPokemonItemViewModel)
        
        sut.loadItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            verify(self.mockFetchPokemonPageUseCase.execute(page: 1)).wasCalled()
            verify(self.mockPokemonItemViewModelFactory
                .createPokemonItemViewModel(from: any())).wasCalled()
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.items.count, 1)
    }
}
