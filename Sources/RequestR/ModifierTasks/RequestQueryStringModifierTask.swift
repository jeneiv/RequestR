//
//  RequestQueryStringModifierTask.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation

public struct RequestQueryStringModifierTask: RequestModifierTask {
    public let queryItems: [URLQueryItem]

    public init(queryItems: [URLQueryItem]) {
        self.queryItems = queryItems
    }

    public func apply(on request: URLRequest) -> URLRequest {
        guard
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            !queryItems.isEmpty
        else { return request }

        var request = request

        components.queryItems = queryItems

        guard let resultURL = components.url else { return request }

        request.url = resultURL
        return request
    }
}
