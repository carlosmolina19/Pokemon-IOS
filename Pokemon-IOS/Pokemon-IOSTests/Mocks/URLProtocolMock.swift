import Foundation

final class URLProtocolMock: URLProtocol {

    // MARK: - Static Internal Properties
    
    static var mockURLs = [URL?: (error: Error?, data: Data?, response: HTTPURLResponse?)]()
    
    // MARK: - Public Class Methods

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    // MARK: - Public Methods
    
    override func startLoading() {
        if let url = request.url {
            if let (error, data, response) = URLProtocolMock.mockURLs[url] {
                
                if let responseStrong = response {
                    self.client?.urlProtocol(self, 
                                             didReceive: responseStrong,
                                             cacheStoragePolicy: .notAllowed)
                }
                
                if let dataStrong = data {
                    self.client?.urlProtocol(self, didLoad: dataStrong)
                }
                
                if let errorStrong = error {
                    self.client?.urlProtocol(self, didFailWithError: errorStrong)
                }
            }
        }
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
