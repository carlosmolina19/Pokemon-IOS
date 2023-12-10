import Combine
import Foundation
import Mockingbird
import XCTest

@testable import Pokemon_IOS

final class RemotePokemonRepositoryImplTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = RemotePokemonRepositoryImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var mockNetworkProvider: NetworkProviderMock!
    private var decoder: JSONDecoder!
    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
        mockNetworkProvider = mock(NetworkProvider.self)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        sut = SUT(networkProvider: mockNetworkProvider, decoder: decoder)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockNetworkProvider = nil
        tasks = nil
        decoder = nil
    }
    
    // MARK: - Tests
    
    func test_fetch_shouldReturnValues() throws {
        let asset = try XCTUnwrap(NSDataAsset(name: "PokemonResponse"))
        let url = try XCTUnwrap(URL(string: "https://pokeapi.co/api/v2/pokemon/1/"))
        
        let expectation = XCTestExpectation(
            description: "test_fetch_shouldReturnValues")
        let publisher = Just(asset.data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        given(mockNetworkProvider.fetch(from: url)).willReturn(publisher)
        
        sut.fetch(number: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTFail("Error wasn't sent \(error.localizedDescription)")
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockNetworkProvider.fetch(from: url)).wasCalled()
        tasks.removeAll()
    }
    
    func test_fetch_whenErrorIsReceived_errorShouldNotBeNil() throws {
        let url = try XCTUnwrap(URL(string: "https://pokeapi.co/api/v2/pokemon/1/"))
        let expectation = XCTestExpectation(
            description: "test_fetch_whenErrorIsReceived_errorShouldNotBeNil")
        let publisher = Fail<Data, Error>(error: NSError(domain: "test.domain",
                                                         code: -1))
            .eraseToAnyPublisher()
        
        given(mockNetworkProvider.fetch(from: url)).willReturn(publisher)
        
        sut.fetch(number: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTAssertNotNil(error)
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
            XCTFail("Error was sent")
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        
        verify(mockNetworkProvider.fetch(from: url)).wasCalled()
        tasks.removeAll()
    }
    
    func test_fetch_whenBadDataIsReceived_errorShouldNotBeNil() throws {
        let data = try XCTUnwrap("bad data".data(using: .utf8))
        let url = try XCTUnwrap(URL(string: "https://pokeapi.co/api/v2/pokemon/1/"))
        
        let expectation = XCTestExpectation(
            description: "test_fetch_whenBadDataIsReceived_shouldNotBeNil")
        let publisher = Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        given(mockNetworkProvider.fetch(from: url)).willReturn(publisher)
        
        sut.fetch(number: 1).sink {
            switch $0 {
            case .failure(let error):
                XCTAssertNotNil(error)
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { _ in
            XCTFail("Bad Data was sent")
        }.store(in: &tasks)
        
        wait(for: [expectation], timeout: 1.0)
        verify(mockNetworkProvider.fetch(from: url)).wasCalled()
        tasks.removeAll()
    }
}
