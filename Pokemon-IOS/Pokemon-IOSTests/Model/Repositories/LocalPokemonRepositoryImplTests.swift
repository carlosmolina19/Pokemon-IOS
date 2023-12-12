import CoreData
import Combine
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class LocalPokemonRepositoryImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = LocalPokemonRepositoryImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var mockLocalProvider: LocalProviderMock!
    private var mockPersistentContainer: NSPersistentContainer!
    private var tasks: Set<AnyCancellable>!
    private var decoder: JSONDecoder!

    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockLocalProvider = mock(LocalProvider.self)
        sut = SUT(localProvider: mockLocalProvider)
        mockPersistentContainer = NSPersistentContainer.mockPersistentContainer()
        given(mockLocalProvider.context).willReturn(mockPersistentContainer.viewContext)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockLocalProvider = nil
        mockPersistentContainer = nil
        tasks = nil
        decoder = nil
    }
    
    // MARK: - Tests
    
    func test_fetch_shouldReturnValues() throws {
        let predicate = NSPredicate(format: "id == %@", "1")
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        let pokemonEntity = Pokemon(pokemonResponseDto: pokemonResponseDto,
                                    pokemonSpeciesDto: pokemonSpecieResponseDto,
                                    context: mockLocalProvider.context)
        
        let expectation = XCTestExpectation(
            description: "test_fetch_shouldReturnValues")
        
        let publisher = Just([pokemonEntity])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        given(mockLocalProvider.fetch(entityType: Pokemon.self, predicate: predicate)).willReturn(publisher)
        
        sut.fetch(pokemonId: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {_ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockLocalProvider.fetch(entityType: Pokemon.self, predicate: predicate)).wasCalled()
        tasks.removeAll()
    }
    
    
    func test_save_shouldBeCalled() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        let expectation = XCTestExpectation(
            description: "test_save_shouldBeCalled")
        let publisher = Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        given(mockLocalProvider.save()).willReturn(publisher)
        
        sut.save(from: pokemonResponseDto,
                 pokemonSpeciesResponseDto: pokemonSpecieResponseDto).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockLocalProvider.save()).wasCalled()
        tasks.removeAll()
    }
}
