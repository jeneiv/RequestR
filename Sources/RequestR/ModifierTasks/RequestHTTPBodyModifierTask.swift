//
//  RequestHTTPBodyModifierTask.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation

public struct RequestHTTPBodyModifierTask: RequestModifierTask {
    public let data: Data

    public func apply(on request: URLRequest) -> URLRequest {
        var request = request
        request.httpBody = data
        return request
    }
}
