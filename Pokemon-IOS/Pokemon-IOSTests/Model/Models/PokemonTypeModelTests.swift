import Foundation
import XCTest

@testable import Pokemon_IOS

final class PokemonTypeModelTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonTypeModel

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
        
        sut = SUT(id: uuid, name: "foo.name", slot: 2)
        
        XCTAssertEqual(sut.id.uuidString, uuid.uuidString)
        XCTAssertEqual(sut.name, "foo.name")
        XCTAssertEqual(sut.slot, 2)
    }
    
    func test_initFromDto_valuesShouldBeEqual() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self, from: asset.data)
        let pokemonTypeDto = try XCTUnwrap(pokemonResponseDto.types.first)

        sut = SUT(dto: pokemonTypeDto)
        
        XCTAssertNotNil(sut.id)
        XCTAssertEqual(sut.name, "grass")
        XCTAssertEqual(sut.slot, 1)
    }
}
