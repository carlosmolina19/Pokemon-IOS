import Foundation
import XCTest

@testable import Pokemon_IOS

final class PokemonAbilityModelTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonAbilityModel

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
        let pokemonAbilityDto = try XCTUnwrap(pokemonResponseDto.abilities.first)

        sut = SUT(dto: pokemonAbilityDto)
        
        XCTAssertNotNil(sut.id)
        XCTAssertEqual(sut.name, "overgrow")
        XCTAssertEqual(sut.slot, 1)
    }
}
