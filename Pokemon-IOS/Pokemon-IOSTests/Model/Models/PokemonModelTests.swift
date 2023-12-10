import Foundation
import XCTest

@testable import Pokemon_IOS

final class PokemonModelTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonModel

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
        let url = try XCTUnwrap(URL(string: "https://tests.com"))
        let uuid = UUID()
        
        sut = SUT(id: uuid, 
                  name: "foo.name",
                  number: 3,
                  abilities: [PokemonAbilityModel](),
                  color: nil,
                  types: [PokemonTypeModel](),
                  url: url)
        
        XCTAssertEqual(sut.id.uuidString, uuid.uuidString)
        XCTAssertEqual(sut.name, "foo.name")
        XCTAssertEqual(sut.number, 3)
        XCTAssertEqual(sut.url.absoluteString, "https://tests.com")
        XCTAssertEqual(sut.abilities.count, 0)
        XCTAssertEqual(sut.types.count, 0)
        XCTAssertNil(sut.color)
    }
    
    func test_initFromDto_valuesShouldBeEqual() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self, from: asset.data)
        let pokemonSpeciesDto = try decoder.decode(PokemonSpeciesResponseDto.self, from: speciesAsset.data)
        
        sut = SUT(dto: pokemonResponseDto, speciesDto: pokemonSpeciesDto)
        
        XCTAssertEqual(sut.name, "bulbasaur")
        XCTAssertEqual(sut.number, 1)
        XCTAssertEqual(sut.url.absoluteString, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        XCTAssertEqual(sut.abilities.count, 2)
        XCTAssertEqual(sut.types.count, 2)
        XCTAssertEqual(sut.color?.name, "blue")
    }
    
    func test_initFromDtoWhenSpeciesDtoIsNil_valuesShouldBeEqual() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self, from: asset.data)
        
        sut = SUT(dto: pokemonResponseDto, speciesDto: nil)
        
        XCTAssertEqual(sut.name, "bulbasaur")
        XCTAssertEqual(sut.number, 1)
        XCTAssertEqual(sut.url.absoluteString, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        XCTAssertEqual(sut.abilities.count, 2)
        XCTAssertEqual(sut.types.count, 2)
        XCTAssertNil(sut.color)
    }
}
