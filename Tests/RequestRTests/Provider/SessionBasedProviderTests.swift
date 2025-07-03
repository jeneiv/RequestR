//
//  SessionBasedProviderTests.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 07. 02..
//

import Foundation
import Testing
@testable import RequestR

@Suite(
    "Tests of SessionBasedProvider",
    .tags(.providerTests)
)
struct SessionBasedProviderTests {
    @Test(
        "Test for creating the provider with an empty constructor call",
        .tags(.providerTests)
    )
    func emptyContructorTest() {
        let sut = SessionBasedProvider<FakeDescriptor>()
        #expect(sut.plugins.isEmpty)
    }
    
    @Test(
        "Test for creating the provider with a plugin",
        .tags(.providerTests)
    )
    func pluginOnlyContructorTest() {
        let plugin = MockPlugin()
        let sut = SessionBasedProvider<FakeDescriptor>(plugins: [plugin])
        #expect(sut.plugins.first as? MockPlugin === plugin)
    }
    
    @Test(
        "Test if `prepare` is called on the plugins",
        .tags(.providerTests)
    )
    func testPluginPrepareCalls() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let fakePlugin = MockPlugin()
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(session: session, plugins: [fakePlugin])
        let _ = try await provider.data(for: descriptor)
        #expect(fakePlugin.prepareCalled == true)
    }
    
    @Test(
        "Test if `prepare` changes are applied on the request",
        .tags(.providerTests)
    )
    func testPluginRequestChanges() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let fakePlugin = MockPlugin()
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(session: session, plugins: [fakePlugin])
        let _ = try await provider.data(for: descriptor)
        #expect(fakePlugin.prepareCalled == true)
    }
    
    @Test(
        "Test if `willSend` is called on the plugins",
        .tags(.providerTests)
    )
    func testPluginWillSendCalls() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(
            session: session,
            plugins: [
                POSTRequestMockPlugin(),
                FakeAuthPlugin()
            ]
        )
        let response = try await provider.data(for: descriptor)
        #expect(response.request.httpMethod == "POST")
        #expect(response.request.allHTTPHeaderFields == ["Authorization" : "Bearer fake-token"])
    }
    
    @Test(
        "Test if `didReceive` is called on the plugins",
        .tags(.providerTests)
    )
    func testPluginDidReceiveCalls() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let fakePlugin = MockPlugin()
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(session: session, plugins: [fakePlugin])
        let _ = try await provider.data(for: descriptor)
        #expect(fakePlugin.didReceiveCalled == true)
    }
    
    @Test(
        "Test `didReceive`'s content",
        .tags(.providerTests)
    )
    func testPluginDidReceiveContent() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let mockPlugin = MockPlugin()
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(session: session, plugins: [mockPlugin])
        let _ = try await provider.data(for: descriptor)
        #expect(mockPlugin.receivedResponse != nil)
        #expect(mockPlugin.receivedResponse?.statusCode == 200)
        #expect(mockPlugin.receivedResponse?.request.httpMethod == "GET")
        #expect(mockPlugin.receivedResponse?.request.allHTTPHeaderFields == [:])
        #expect(mockPlugin.receivedResponse?.response.url == URL(string: "http://fake.descriptor.net/something")!)
        #expect(mockPlugin.receivedResponse?.response.statusCode == 200)
        #expect(mockPlugin.receivedResponse?.response.allHeaderFields as? [String: String] == ["Content-Type": "application/json"])
    }
    
    @Test(
        "Test if the provider throws an error when not an HTTPURLResponse is returned",
        .tags(.providerTests)
    )
    func testResponseTypeMismatchError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLResponseReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(session: session)
        
        await #expect(throws: RequestProviderErrorError.self, performing: {
            let _ = try await provider.data(for: descriptor)
        })
    }
    
    @Test(
        "Test if the returned result reflects what the URLSession provides",
        .tags(.providerTests)
    )
    func testResultContent() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(session: session)
        let result = try await provider.data(for: descriptor)
        #expect(result.statusCode == 200)
        #expect(result.request.httpMethod == "GET")
        #expect(result.request.allHTTPHeaderFields == [:])
        #expect(result.response.url == URL(string: "http://fake.descriptor.net/something")!)
        #expect(result.response.statusCode == 200)
        #expect(result.response.allHeaderFields as? [String: String] == ["Content-Type": "application/json"])
        #expect(result.data == """
                    {"hello": "world"}
                """.data(using: .utf8)!)
    }
    
    @Test(
        "Test if plugin `process` calls are being made and applied on the response",
        .tags(.providerTests)
    )
    func testPluginProcessCall() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldDictionaryReturningMockURLprotocol.self]
        let session = URLSession(configuration: config)
        
        let descriptor = FakeDescriptor()
        let provider = SessionBasedProvider<FakeDescriptor>(
            session: session,
            plugins: [
                ResponseHTTPStatusAlteringPlugin(),
                ResponseDataOverridingPlugin()
            ]
        )
        let result = try await provider.data(for: descriptor)
        #expect(result.statusCode == 201)
        #expect(result.request.httpMethod == "GET")
        #expect(result.request.allHTTPHeaderFields == [:])
        #expect(result.response.url == URL(string: "http://fake.descriptor.net/something")!)
        #expect(result.response.statusCode == 201)
        #expect(result.response.allHeaderFields as? [String: String] == ["Content-Type": "application/json"])
        #expect(result.data == """
                {"world": "hello"}
                """.data(using: .utf8)!)
    }
}

// MARK: - Test Doubles

// MARK: Plugins

fileprivate class MockPlugin: Plugin {
    var prepareCalled = false
    var willSendCalled = false
    var didReceiveCalled = false
    var processCalled = false

    var receivedResponse: Response?

    func prepare(_ request: URLRequest, descriptor: any RequestDescriptor) -> URLRequest {
        prepareCalled = true
        return request
    }

    func willSend(_ request: URLRequest, descriptor: any RequestDescriptor) {
        willSendCalled = true
    }

    func didReceive(_ response: Response, descriptor: any RequestDescriptor) {
        didReceiveCalled = true
        receivedResponse = response
    }

    func process(_ response: Response, descriptor: any RequestDescriptor) -> Response {
        processCalled = true
        return response
    }
}

fileprivate class POSTRequestMockPlugin: Plugin {
    func prepare(_ request: URLRequest, descriptor: any RequestDescriptor) -> URLRequest {
        var newRequest = request
        newRequest.httpMethod = "POST"
        return newRequest
    }
}

fileprivate class FakeAuthPlugin: Plugin {
    func prepare(_ request: URLRequest, descriptor: any RequestDescriptor) -> URLRequest {
        var newRequest = request
        newRequest.allHTTPHeaderFields = ["Authorization" : "Bearer fake-token"]
        return newRequest
    }
}

fileprivate class ResponseHTTPStatusAlteringPlugin: Plugin {
    func process(_ response: Response, descriptor: any RequestDescriptor) -> Response {
        Response(
            statusCode: 201,
            data: response.data,
            request: response.request,
            response: HTTPURLResponse(
                url: response.response.url!,
                statusCode: 201,
                httpVersion: nil,
                headerFields: response.response.allHeaderFields as? [String: String]
            )!
        )
    }
}

fileprivate class ResponseDataOverridingPlugin: Plugin {
    func process(_ response: Response, descriptor: any RequestDescriptor) -> Response {
        Response(
            statusCode: 201,
            data: """
                {"world": "hello"}
                """.data(using: .utf8)!,
            request: response.request,
            response: response.response
        )
    }
}

// MARK: Request Descriptors

fileprivate class FakeDescriptor: RequestDescriptor {
    var baseURL: URL {
        URL(string: "http://fake.descriptor.net")!
    }

    var path: String { "something" }
    var method: RequestR.Method { .get }
    var tasks: [any RequestModifierTask]? { nil }
    var headers: [String: String]? { nil }
}

// MARK: URLProtocols

class URLResponseReturningMockURLprotocol: MockURLProtocol {
    override class var mockResponses: [String: MockURLProtocolResponse] {
        [
            "http://fake.descriptor.net/something": .response(
                Data(),
                URLResponse(
                    url: URL(string: "http://fake.descriptor.net/something")!,
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil
                )
            )
        ]
    }
}

class HelloWorldDictionaryReturningMockURLprotocol: MockURLProtocol {
    override class var mockResponses: [String: MockURLProtocolResponse] {
        [
            "http://fake.descriptor.net/something": .response(
                """
                    {"hello": "world"}
                """.data(using: .utf8)!,
                HTTPURLResponse(
                    url: URL(string: "http://fake.descriptor.net/something")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
            )
        ]
    }
}

// MARK: - Mocking Implementation

class MockURLProtocol: URLProtocol {
    enum MockURLProtocolResponse {
        case response(Data, URLResponse)
        case error(Error)
    }

    enum MockError: Error {
        case cannotResolveURL
    }

    class var mockResponses: [String: MockURLProtocolResponse] {
        [:]
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url, let mockResponse = Self.mockResponses[url.absoluteString] else {
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

    override func stopLoading() {
        // Intentionally left blank
    }
}
