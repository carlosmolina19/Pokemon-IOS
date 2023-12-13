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
    
    func test_create_shouldReturnNotNil() {
        XCTAssertNotEqual(sut.create(ofType: Pokemon.self), mockPersistentContainer.viewContext)
    }
    
    func test_fetch_shouldBeFulFill() throws {
        let pokemonEntity = sut.create(ofType: Pokemon.self)
        let expectation = expectation(description: "test_fetch_shouldBeFulFill")
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
        let expectation = XCTestExpectation(description: "test_save_shouldBeFulFill")

        sut.save().sink { _ in
        } receiveValue: { _ in
            expectation.fulfill()
        }.store(in: &tasks)
        
        wait(for: [expectation])
        tasks.removeAll()
    }
}
