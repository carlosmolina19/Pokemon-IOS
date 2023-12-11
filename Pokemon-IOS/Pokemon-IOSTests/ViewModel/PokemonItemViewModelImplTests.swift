import SwiftUI
import XCTest

@testable import Pokemon_IOS

final class PokemonItemViewModelImplTests: XCTestCase {

    // MARK: - Typealias

    private typealias SUT = PokemonItemViewModelImpl
    private var decoder: JSONDecoder!

    // MARK: - Private Properties

    private var sut: SUT!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    override func tearDown() {
        super.tearDown()
        
        sut = nil
        decoder = nil
    }

    // MARK: - Tests

    func test_init_shouldReturnValues() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        
        let pokemonModel = PokemonModel(dto: pokemonResponseDto,
                                        speciesDto: pokemonSpecieResponseDto)
        
        sut = SUT(model: pokemonModel)

        XCTAssertEqual(pokemonModel.name, sut.name)
        XCTAssertEqual(sut.number, "#0001")
        XCTAssertEqual(sut.abilities.first, "overgrow")
        XCTAssertEqual(sut.types.first, "grass")
        XCTAssertEqual(sut.backgroundColor, Color("blue"))
        XCTAssertEqual(pokemonModel.url, sut.url)
    }
}
