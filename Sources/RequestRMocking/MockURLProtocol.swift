//
//  MockURLProtocol.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 07. 03..
//

import Foundation

open class MockURLProtocol: URLProtocol {
    public enum MockURLProtocolResponse {
        case response(Data, URLResponse)
        case error(Error)
    }

    enum MockError: Error {
        case cannotResolveURL
    }

    open class var mockResponses: [String: MockURLProtocolResponse] {
        [:]
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        guard let url = request.url, let strippedURL = url.strippedOfQueryString(), let mockResponse = Self.mockResponses[strippedURL.absoluteString] else {
            client?.urlProtocol(self, didFailWithError: MockError.cannotResolveURL)
            return
        }

        switch mockResponse {
        case .response(let data, let response):
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        case .error(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    public override func stopLoading() {
        // Intentionally left blank
    }
}

private extension URL {
    func strippedOfQueryString() -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = nil
        return components.url
    }
}
