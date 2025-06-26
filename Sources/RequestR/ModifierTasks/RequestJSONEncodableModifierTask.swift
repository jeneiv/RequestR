//
//  RequestJSONEncodableModifierTask.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation

public struct RequestJSONEncodableModifierTask: RequestModifierTask {
    public let encodable: Encodable
    public var encoder = JSONEncoder()

    public func apply(on request: URLRequest) throws(RequestModifierTaskError) -> URLRequest {
        var request = request
        do {
            let requestData = try encoder.encode(encodable)
            request.httpBody = requestData
            if request.allHTTPHeaderFields?["Content-Type"] == nil {
                request.allHTTPHeaderFields?["Content-Type"] = "application/json"
            }
        } catch {
            throw RequestModifierTaskError.JSONEncodeError(error)
        }
        return request
    }
}
