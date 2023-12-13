import Combine
import Foundation
import XCTest

@testable import Pokemon_IOS

final class NetworkProviderTests: XCTestCase {
    
    // MARK: - Private Typealias
    
    private typealias SUT = NetworkProviderImpl
    
    // MARK: - Private Properties
    
    private var sut: SUT!
    private var mockSession: URLSession!
    private var tasks: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        tasks = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        mockSession = nil
        tasks = nil
        
    }
    
    // MARK: - Tests
    
    func test_fetch_shouldReturnValues() throws {
        let url = try XCTUnwrap(URL(string: "https://tests.com"))
        let data = try XCTUnwrap("{\"someJsonKey\": \"someJsonData\"}".data(using: .utf8))
        let response = HTTPURLResponse()
        
        URLProtocolMock.mockURLs = [url: (nil, data, response)]
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        mockSession = URLSession(configuration: sessionConfiguration)
        
        sut = SUT(session: mockSession)
        
        let expectation = XCTestExpectation(description: "test_fetch_shouldReturnValues")
        
        sut.fetch(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { dataResponse in
                XCTAssertEqual(data, dataResponse)
            })
            .store(in: &tasks)
        
        
        wait(for: [expectation], timeout: 1.0)
        tasks.removeAll()
    }
    
    func test_fetch_whenErrorIsReceived_shouldNotBeNil() throws {
        let url = try XCTUnwrap(URL(string: "https://tests.com"))
        
        
        let error = NSError(domain: "test.domain", code: -1)
        
        let response = HTTPURLResponse()
        
        URLProtocolMock.mockURLs = [url: (error, nil, response)]
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        mockSession = URLSession(configuration: sessionConfiguration)
        
        sut = SUT(session: mockSession)
        
        let expectation = XCTestExpectation(
            description: "test_fetch_whenErrorIsReceived_shouldBeEqual")
        
        sut.fetch(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                    
                case .failure(let errorResponse):
                    XCTAssertNotNil(errorResponse)
                    
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { dataResponse in
                XCTFail("Data wasn't sent")
            })
            .store(in: &tasks)
        
        
        wait(for: [expectation], timeout: 1.0)
        tasks.removeAll()
    }
    
    func test_fetch_whenStatusCodeIsNotFound_shouldNotBeNil() throws {
        let url = try XCTUnwrap(URL(string: "https://tests.com"))
        
        let response = HTTPURLResponse(url: url,
                                       statusCode: 404,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        
        URLProtocolMock.mockURLs = [url: (nil, nil, response)]
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        mockSession = URLSession(configuration: sessionConfiguration)
        
        sut = SUT(session: mockSession)
        
        let expectation = XCTestExpectation(
            description: "test_fetch_whenErrorIsReceived_shouldBeEqual")
        
        sut.fetch(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                    
                case .failure(let errorResponse):
                    XCTAssertEqual((errorResponse as NSError).code, 404)
                    
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { dataResponse in
                XCTFail("Data wasn't sent")
            })
            .store(in: &tasks)
        
        
        wait(for: [expectation], timeout: 1.0)
        tasks.removeAll()
    }
}
