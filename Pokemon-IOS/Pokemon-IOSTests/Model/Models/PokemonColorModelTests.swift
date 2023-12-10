import Foundation
import XCTest

@testable import Pokemon_IOS

final class PokemonColorModelTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonColorModel

    // MARK: - Private Properties

    private var sut: SUT!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    // MARK: - Tests
    
    func test_init_valuesShouldBeEqual() throws {
        let uuid = UUID()
        
        sut = SUT(id: uuid, name: "foo.name")
        
        XCTAssertEqual(sut.id.uuidString, uuid.uuidString)
        XCTAssertEqual(sut.name, "foo.name")
    }
    
    func test_initFromDto_valuesShouldBeEqual() throws {
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemonSpeciesResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                           from: speciesAsset.data)

        sut = SUT(dto: pokemonSpeciesResponseDto.color)
        
        XCTAssertNotNil(sut.id)
        XCTAssertEqual(sut.name, "blue")
    }
}

