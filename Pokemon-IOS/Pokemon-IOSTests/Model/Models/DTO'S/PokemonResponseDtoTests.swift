import Foundation
import XCTest

@testable import Pokemon_IOS

final class PokemonResponseDtoTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonResponseDto

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
    
    func test_initFromDecode_valuesShouldBeEqual() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        sut = try decoder.decode(SUT.self, from: asset.data)
        XCTAssertEqual(sut.id, 1)
        XCTAssertEqual(sut.name, "bulbasaur")
        XCTAssertEqual(sut.abilities.count, 2)
        XCTAssertEqual(sut.sprites.frontDefault.absoluteString, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        XCTAssertEqual(sut.types.count, 2)
        XCTAssertEqual(sut.id, 1)
        XCTAssertEqual(sut.species.name, "bulbasaur")

    }
}
