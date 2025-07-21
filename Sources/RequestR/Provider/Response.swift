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

public extension Response {
    var isSuccessResponse: Bool {
        (200...299).contains(self.statusCode)
    }
    
    var isRedirectionResponse: Bool {
        (300...399).contains(self.statusCode)
    }
    
    var isClientErrorResponse: Bool {
        (400...499).contains(self.statusCode)
    }
    
    var isServerErrorResponse: Bool {
        (500...599).contains(self.statusCode)
    }
}
