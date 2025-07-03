//
//  URLSessionBasedProvider.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 07. 02..
//

import Foundation

public enum RequestProviderErrorError: Error {
    case responseTypeMismatch
}

public struct SessionBasedProvider<Descriptor: RequestDescriptor> {
    private let session: URLSession
    let plugins: [any Plugin]

    public init(plugins: [any Plugin] = []) {
        self.init(session: URLSession.shared, plugins: plugins)
    }

    public init(session: URLSession, plugins: [any Plugin] = []) {
        self.session = session
        self.plugins = plugins
    }

    public func data(for descriptor: Descriptor, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> Response {
        var urlRequest = try descriptor.toURLRequest()
        plugins.forEach { urlRequest = $0.prepare(urlRequest, descriptor: descriptor) }
        plugins.forEach { $0.willSend(urlRequest, descriptor: descriptor) }
        let sessionResponse: (data: Data, response: URLResponse) = try await session.data(for: urlRequest, delegate: delegate)
        guard let httpURLResponse = sessionResponse.response as? HTTPURLResponse else {
            throw RequestProviderErrorError.responseTypeMismatch
        }
        var response = Response(
            statusCode: httpURLResponse.statusCode,
            data: sessionResponse.data,
            request: urlRequest,
            response: httpURLResponse
        )
        plugins.forEach { $0.didReceive(response, descriptor: descriptor) }
        plugins.forEach { response = $0.process(response, descriptor: descriptor) }
        return response
    }
}
