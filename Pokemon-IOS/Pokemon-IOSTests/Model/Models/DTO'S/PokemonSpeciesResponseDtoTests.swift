import Foundation
import XCTest

@testable import Pokemon_IOS

final class PokemonSpeciesDtoTests: XCTestCase {
    
    // MARK: - Typealias
    
    private typealias SUT = PokemonSpeciesResponseDto

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
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        sut = try decoder.decode(SUT.self, from: asset.data)
        
        XCTAssertEqual(sut.color.name, "blue")
    }
}
