import CoreData
import Combine
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class SavePokemonDetailUseCaseImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = SavePokemonDetailUseCaseImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var decoder: JSONDecoder!
    private var mockLocalPokemonRepository: LocalPokemonRepositoryMock!
    private var mockPersistentContainer: NSPersistentContainer!
    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockLocalPokemonRepository = mock(LocalPokemonRepository.self)
        mockPersistentContainer = NSPersistentContainer.mockPersistentContainer()
        sut = SUT(localPokemonRepository: mockLocalPokemonRepository)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockLocalPokemonRepository = nil
        mockPersistentContainer = nil
        tasks = nil
        decoder = nil
    }
    
    // MARK: - Tests
    
    func test_execute_shouldCallToRepository() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        let pokemonModel = PokemonModel(dto: pokemonResponseDto,
                                       speciesDto: pokemonSpecieResponseDto)
        
        let pokemonEntity = Pokemon(model: pokemonModel,
                context: mockPersistentContainer.viewContext)
        
        let publisher = Just(pokemonEntity)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()

        
        let expectation = XCTestExpectation(
            description: "test_execute_shouldCallToRepository")
        
        
        given(mockLocalPokemonRepository.save(from: any())).willReturn(publisher)
        
        sut.execute(model: pokemonModel).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {
            XCTAssertEqual($0.name, pokemonEntity.name)
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockLocalPokemonRepository.save(from: any())).wasCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenLocalPokemonRepositoryReturnError_shouldBeFulFill() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        let pokemonModel = PokemonModel(dto: pokemonResponseDto,
                                       speciesDto: pokemonSpecieResponseDto)
        let expectation = XCTestExpectation(
            description: "test_execute_whenLocalPokemonRepositoryReturnError_shouldNotCallToRemoteSpecieRepository")
        
        let errorPublisher = Fail<Pokemon, PokemonError>(error:PokemonError.invalidFormat).eraseToAnyPublisher()
        
        
        given(mockLocalPokemonRepository.save(from: any())).willReturn(errorPublisher)
        
        sut.execute(model: pokemonModel).sink {
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
        verify(mockLocalPokemonRepository.save(from: any())).wasCalled()
        tasks.removeAll()
    }
}
