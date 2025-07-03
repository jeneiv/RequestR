//
//  Response.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 07. 02..
//

import Foundation

public struct Response {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest
    public let response: HTTPURLResponse
}
