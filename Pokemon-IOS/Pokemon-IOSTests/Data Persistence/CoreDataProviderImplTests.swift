import Combine
import CoreData
import Foundation
import XCTest

@testable import Pokemon_IOS

final class CoreDataProviderImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = CoreDataProviderImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var mockPersistentContainer: NSPersistentContainer!
    private var decoder: JSONDecoder!
    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockPersistentContainer = NSPersistentContainer.mockPersistentContainer()
        sut = SUT(persistentContainer: mockPersistentContainer)
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockPersistentContainer = nil
        decoder = nil
        tasks = nil
    }
    
    // MARK: - Tests
    
    func test_context_shouldBeEqual() {
        XCTAssertNotEqual(sut.context.parent, mockPersistentContainer.viewContext)
    }
    
    func test_fetch_shouldBeFulFill() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        
        let expectation = expectation(description: "test_fetch_shouldBeFulFill")
        let pokemonEntity = Pokemon(pokemonResponseDto: pokemonResponseDto,
                                    pokemonSpeciesDto: pokemonSpecieResponseDto,
                                    context: sut.context)
        
        let predicate = NSPredicate(format: "id == %@", String(pokemonEntity.id))
        sut.fetch(entityType: Pokemon.self, predicate: predicate)
            .sink { _ in
            } receiveValue: { _ in
                expectation.fulfill()
            }.store(in: &tasks)
        
        waitForExpectations(timeout: 1.0)
        tasks.removeAll()
    }
    
    func test_save_shouldBeFulFill() throws {
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: sut.context)
        
        sut.save().sink { _ in
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
        tasks.removeAll()
    }
}
