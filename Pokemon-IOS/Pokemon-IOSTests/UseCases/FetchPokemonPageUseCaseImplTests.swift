import Combine
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class FetchPokemonPageUseCaseImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = FetchPokemonPageUseCaseImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var decoder: JSONDecoder!
    private var mockPokemonDetailUseCase: FetchPokemonDetailUseCaseMock!
    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockPokemonDetailUseCase = mock(FetchPokemonDetailUseCase.self)
        sut = SUT(pokemonDetailUseCase: mockPokemonDetailUseCase)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockPokemonDetailUseCase = nil
        tasks = nil
        decoder = nil
    }
    
    // MARK: - Tests
    
    func test_execute_shouldCallToDetailUseCase() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let model = PokemonModel(dto: pokemonResponseDto, speciesDto: nil)
        
        let publisher = Just(model)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(
            description: "test_execute_shouldCallToDetailUseCase")
        
        given(mockPokemonDetailUseCase.execute(number: any())).willReturn(publisher)
        
        sut.execute(page: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {
            XCTAssertEqual($0.count, 20)
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockPokemonDetailUseCase.execute(number: 1)).wasCalled()
        verify(mockPokemonDetailUseCase.execute(number: 20)).wasCalled()
        verify(mockPokemonDetailUseCase.execute(number: 21)).wasNeverCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenErrorNotFoundIsRceived_shouldCallToRepository() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let model = PokemonModel(dto: pokemonResponseDto, speciesDto: nil)
        
        let publisher = Just(model)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
        
        let publisherError = Fail<PokemonModel, PokemonError>(error:PokemonError.notFound)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(
            description: "test_execute_whenErrorNotFoundIsRceived_shouldCallToRepository")
                
        given(mockPokemonDetailUseCase.execute(number: any())).willReturn(publisher)
        given(mockPokemonDetailUseCase.execute(number: 20)).willReturn(publisherError)

        sut.execute(page: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {
            XCTAssertEqual($0.count, 19)
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockPokemonDetailUseCase.execute(number: 1)).wasCalled()
        verify(mockPokemonDetailUseCase.execute(number: 20)).wasCalled()
        verify(mockPokemonDetailUseCase.execute(number: 21)).wasNeverCalled()
        tasks.removeAll()
    }
}
