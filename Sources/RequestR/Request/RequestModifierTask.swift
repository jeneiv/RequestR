//
//  RequestModifierTask.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation

public enum RequestModifierTaskError: Error {
    case JSONEncodeError(any Error)
}

public protocol RequestModifierTask {
    func apply(on request: URLRequest) throws(RequestModifierTaskError) -> URLRequest
}
