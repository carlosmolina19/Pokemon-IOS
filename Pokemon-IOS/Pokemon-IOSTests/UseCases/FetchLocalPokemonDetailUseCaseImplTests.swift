import Combine
import CoreData
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class FetchLocalPokemonDetailUseCaseImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = FetchLocalPokemonDetailUseCaseImpl
    
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
    
    func test_execute_shouldCallToRepository() {
        let pokemonEntity = Pokemon(with: mockPersistentContainer.viewContext)
        let pokemonAbility = PokemonAbility(with: mockPersistentContainer.viewContext)
        let pokemonType = PokemonType(with: mockPersistentContainer.viewContext)

        pokemonEntity.id = 1
        pokemonEntity.name = "foo.name"
        pokemonEntity.url = "www.foo.com"
        pokemonAbility.name = "foo.ability"
        pokemonType.name = "foo.type"
        pokemonEntity.addToAbilities(pokemonAbility)
        pokemonEntity.addToTypes(pokemonType)
        
        let publisher = Just(pokemonEntity)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()

        
        let expectation = XCTestExpectation(
            description: "test_execute_shouldCallToRepository")
        
        
        given(mockLocalPokemonRepository.fetch(number: 1)).willReturn(publisher)
        
        sut.execute(number: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockLocalPokemonRepository.fetch(number: 1)).wasCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenLocalPokemonRepositoryReturnError_shouldNotCallToRemoteSpecieRepository() {
        let expectation = XCTestExpectation(
            description: "test_execute_whenLocalPokemonRepositoryReturnError_shouldNotCallToRemoteSpecieRepository")
        
        let errorPublisher = Fail<Pokemon, PokemonError>(error:PokemonError.invalidFormat).eraseToAnyPublisher()
        
        
        given(mockLocalPokemonRepository.fetch(number: 1)).willReturn(errorPublisher)
        
        sut.execute(number: 1).sink {
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
        verify(mockLocalPokemonRepository.fetch(number: 1)).wasCalled()
        tasks.removeAll()
    }
    
    func test_executeWhenPokemonHasMissingInfo_shouldCallToRepository() throws {
        let pokemonEntity = Pokemon(with: mockPersistentContainer.viewContext)
        
        let publisher = Just(pokemonEntity)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()

        
        let expectation = XCTestExpectation(
            description: "test_execute_shouldCallToRepository")
        
        
        given(mockLocalPokemonRepository.fetch(number: 1)).willReturn(publisher)
        
        sut.execute(number: 1).sink {
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
        verify(mockLocalPokemonRepository.fetch(number: 1)).wasCalled()
        tasks.removeAll()
    }
}
