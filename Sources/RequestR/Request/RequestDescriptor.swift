//
//  RequestDescriptor.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation

public protocol RequestDescriptor {
    var baseURL: URL { get }
    var path: String { get }
    var method: Method { get }
    var tasks: [any RequestModifierTask]? { get }
    var headers: [String: String]? { get }
}

public extension RequestDescriptor {
    func toURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        try tasks?.forEach { modifier in
            request = try modifier.apply(on: request)
        }
        return request
    }
}
