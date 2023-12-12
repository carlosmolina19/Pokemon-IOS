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
    private var mockFetchLocalPokemonDetailUseCase: FetchLocalPokemonDetailUseCaseMock!
    private var mockSavePokemonDetailUseCase: SavePokemonDetailUseCaseMock!

    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockPokemonDetailUseCase = mock(FetchPokemonDetailUseCase.self)
        mockFetchLocalPokemonDetailUseCase = mock(FetchLocalPokemonDetailUseCase.self)
        mockSavePokemonDetailUseCase = mock(SavePokemonDetailUseCase.self)

        sut = SUT(pokemonDetailUseCase: mockPokemonDetailUseCase,
                  fetchLocalPokemonDetailUseCase: mockFetchLocalPokemonDetailUseCase,
                  savePokemonDetailUseCase: mockSavePokemonDetailUseCase
        )
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockPokemonDetailUseCase = nil
        mockFetchLocalPokemonDetailUseCase = nil
        mockSavePokemonDetailUseCase = nil
        tasks = nil
        decoder = nil
    }
    
    // MARK: - Tests
    
    func test_execute_shouldBeFulFill() throws {
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
        given(mockSavePokemonDetailUseCase.execute(model: any())).willReturn(publisher)

        sut.execute(page: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {
            XCTAssertEqual($0.count, 10)
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockPokemonDetailUseCase.execute(number: any())).wasCalled(exactly(10))
        verify(mockFetchLocalPokemonDetailUseCase.execute(number: any())).wasNeverCalled()
        verify(mockSavePokemonDetailUseCase.execute(model: any())).wasCalled(exactly(10))
        tasks.removeAll()
    }
    
    func test_execute_whenErrorNotFoundIsRceived_shouldBeFulFill() {
        let errorPublisher = Fail<PokemonModel, PokemonError>(error: PokemonError.notFound).eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(
            description: "test_execute_whenErrorNotFoundIsRceived_shouldCallToRepository")
                
        given(mockPokemonDetailUseCase.execute(number: any())).willReturn(errorPublisher)
        given(mockSavePokemonDetailUseCase.execute(model: any())).willReturn(errorPublisher)

        sut.execute(page: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTAssertEqual(error, .notFound)
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockPokemonDetailUseCase.execute(number: any())).wasCalled(exactly(1))
        verify(mockFetchLocalPokemonDetailUseCase.execute(number: any())).wasNeverCalled()
        verify(mockSavePokemonDetailUseCase.execute(model: any())).wasNeverCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenErrorIsRceived_shouldBeFulFill() {
        let errorPublisher = Fail<PokemonModel, PokemonError>(error: PokemonError.invalidFormat).eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(
            description: "test_execute_whenErrorIsRceived_shouldCallFetchLocal")
                
        given(mockPokemonDetailUseCase.execute(number: any())).willReturn(errorPublisher)
        given(mockFetchLocalPokemonDetailUseCase.execute(number: any())).willReturn(errorPublisher)

        sut.execute(page: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTAssertEqual(error, .invalidFormat)
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockPokemonDetailUseCase.execute(number: any())).wasCalled(exactly(1))
        verify(mockFetchLocalPokemonDetailUseCase.execute(number: any())).wasCalled(exactly(1))
        verify(mockSavePokemonDetailUseCase.execute(model: any())).wasNeverCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenFetchLocalPokenIsCalled_shouldReturnAValue() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let model = PokemonModel(dto: pokemonResponseDto, speciesDto: nil)
        let publisher = Just(model)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
        
        let errorPublisher = Fail<PokemonModel, PokemonError>(error: PokemonError.invalidFormat).eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(
            description: "test_execute_whenErrorNotFoundIsRceived_shouldCallToRepository")
                
        given(mockPokemonDetailUseCase.execute(number: any())).willReturn(errorPublisher)
        given(mockFetchLocalPokemonDetailUseCase.execute(number: any())).willReturn(publisher)

        sut.execute(page: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {
            XCTAssertEqual($0.count, 10)
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockPokemonDetailUseCase.execute(number: any())).wasCalled(exactly(10))
        verify(mockFetchLocalPokemonDetailUseCase.execute(number: any())).wasCalled(exactly(10))
        verify(mockSavePokemonDetailUseCase.execute(model: any())).wasNeverCalled()
        tasks.removeAll()
    }
}
