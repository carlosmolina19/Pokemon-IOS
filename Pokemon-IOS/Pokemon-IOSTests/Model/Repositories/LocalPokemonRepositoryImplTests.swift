import Combine
import CoreData
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
        
        given(mockLocalProvider.create(ofType: Pokemon.self))
            .willReturn(Pokemon(with: mockPersistentContainer.viewContext))
        
        given(mockLocalProvider.create(ofType: PokemonAbility.self))
            .willReturn(PokemonAbility(with: mockPersistentContainer.viewContext))
        
        given(mockLocalProvider.create(ofType: PokemonType.self))
            .willReturn(PokemonType(with: mockPersistentContainer.viewContext))
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
        let pokemonEntity = Pokemon(with: mockPersistentContainer.viewContext)
        pokemonEntity.id = 1
        let predicate = NSPredicate(format: "id == %@", String(1))
        
        let expectation = XCTestExpectation(
            description: "test_fetch_shouldReturnValues")
        
        let publisher = Just([pokemonEntity])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        given(mockLocalProvider.fetch(entityType: Pokemon.self, predicate: predicate)).willReturn(publisher)
        
        sut.fetch(number: 1).sink {
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
        verify(mockLocalProvider.fetch(entityType: Pokemon.self,
                                       predicate: predicate)).wasCalled()
        tasks.removeAll()
    }
    
    
    func test_save_shouldBeCalled() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        let pokemonModel = PokemonModel(dto: pokemonResponseDto,
                                        speciesDto: pokemonSpecieResponseDto)
        
        let pokemonEntity = Pokemon(with: mockPersistentContainer.viewContext)
        pokemonEntity.id = Int16(pokemonModel.number)
        
        let expectation = XCTestExpectation(
            description: "test_save_shouldBeCalled")
        let publisher = Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let publisherFetch = Just([pokemonEntity])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        given(mockLocalProvider.save()).willReturn(publisher)
        given(mockLocalProvider.fetch(entityType: Pokemon.self, predicate: any())).willReturn(publisherFetch)
        
        sut.save(from: pokemonModel)
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: {
                XCTAssertEqual(pokemonEntity.id, $0.id)
            }
            .store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockLocalProvider.save()).wasCalled()
        verify(mockLocalProvider.fetch(entityType: Pokemon.self,
                                       predicate: any())).wasCalled()
        verify(mockLocalProvider.create(ofType: Pokemon.self)).wasNeverCalled()
        tasks.removeAll()
    }
    

}
