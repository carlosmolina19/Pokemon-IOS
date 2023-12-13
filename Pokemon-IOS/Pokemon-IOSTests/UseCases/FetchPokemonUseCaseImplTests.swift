import Combine
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class FetchPokemonDetailUseCaseImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = FetchPokemonDetailUseCaseImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var decoder: JSONDecoder!
    private var mockRemotePokemonRepository: RemotePokemonRepositoryMock!
    private var mockRemotePokemonSpecieRepository: RemotePokemonSpecieRepositoryMock!
    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        mockRemotePokemonRepository = mock(RemotePokemonRepository.self)
        mockRemotePokemonSpecieRepository = mock(RemotePokemonSpecieRepository.self)
        sut = SUT(remotePokemonRepository: mockRemotePokemonRepository,
                  remotePokemonSpeciesRepository: mockRemotePokemonSpecieRepository)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockRemotePokemonRepository = nil
        mockRemotePokemonSpecieRepository = nil
        tasks = nil
        decoder = nil
    }
    
    // MARK: - Tests
    
    func test_execute_shouldCallToRepository() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let speciesAsset = try XCTUnwrap(NSDataAsset(name: "PokemonSpeciesResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        let pokemonSpecieResponseDto = try decoder.decode(PokemonSpeciesResponseDto.self,
                                                          from: speciesAsset.data)
        
        let publisher = Just(pokemonResponseDto)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
    
        let publisherSpecie = Just(pokemonSpecieResponseDto)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(
            description: "test_execute_shouldCallToRepository")
        
        
        given(mockRemotePokemonRepository.fetch(number: 1)).willReturn(publisher)
        given(mockRemotePokemonSpecieRepository.fetch(number: 1)).willReturn(publisherSpecie)
        
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
        verify(mockRemotePokemonRepository.fetch(number: 1)).wasCalled()
        verify(mockRemotePokemonSpecieRepository.fetch(number: 1)).wasCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenRemotePokemonRepositoryReturnError_shouldNotCallToRemoteSpecieRepository() {
        let expectation = XCTestExpectation(
            description: "test_execute_whenRemotePokemonRepositoryReturnError_shouldNotCallToRemoteSpecieRepository")
        
        let errorPublisher = Fail<PokemonResponseDto, PokemonError>(error:PokemonError.invalidFormat).eraseToAnyPublisher()
        
        let publisher = Fail<PokemonSpeciesResponseDto, PokemonError>(error:PokemonError.invalidFormat).eraseToAnyPublisher()
        
        given(mockRemotePokemonRepository.fetch(number: 1)).willReturn(errorPublisher)
        given(mockRemotePokemonSpecieRepository.fetch(number: 1)).willReturn(publisher)
        
        sut.execute(number: 1).sink {
            switch $0 {
            case .failure(let error):
               XCTAssertNotNil(error)
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockRemotePokemonRepository.fetch(number: 1)).wasCalled()
        verify(mockRemotePokemonSpecieRepository.fetch(number: 1)).wasNeverCalled()
        tasks.removeAll()
    }
    
    func test_execute_whenRemotePokemonSpecieRepositoryReturnAnError_shouldNotBeNil() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let pokemonResponseDto = try decoder.decode(PokemonResponseDto.self,
                                                    from: asset.data)
        let expectation = XCTestExpectation(
            description: "test_execute_whenRemotePokemonSpecieRepositoryReturnAnError_shouldNotBeNil")
        
        let errorPublisher = Fail<PokemonSpeciesResponseDto, PokemonError>(error:PokemonError.invalidFormat).eraseToAnyPublisher()
        
        let publisher = Just(pokemonResponseDto)
            .setFailureType(to: PokemonError.self)
            .eraseToAnyPublisher()
        
        given(mockRemotePokemonRepository.fetch(number: 1)).willReturn(publisher)
        given(mockRemotePokemonSpecieRepository.fetch(number: 1)).willReturn(errorPublisher)
        
        sut.execute(number: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent: \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: {
            XCTAssertNotNil($0)
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockRemotePokemonRepository.fetch(number: 1)).wasCalled()
        verify(mockRemotePokemonSpecieRepository.fetch(number: 1)).wasCalled()
        tasks.removeAll()
    }
}
