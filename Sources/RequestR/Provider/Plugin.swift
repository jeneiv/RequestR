//
//  Plugin.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 07. 02..
//

import Foundation

public protocol Plugin {
    /// Is called to alter the request before sending it
    func prepare(_ request: URLRequest, descriptor: any RequestDescriptor) -> URLRequest

    /// Is called just ebfore the request is sent
    func willSend(_ request: URLRequest, descriptor: any RequestDescriptor)

    /// Is called after the request has been received, but before `process`
    func didReceive(_ response: Response, descriptor: any RequestDescriptor)

    // Called before the provider returns with the `Response`
    func process(_ response: Response, descriptor: any RequestDescriptor) -> Response
}

public extension Plugin {
    func prepare(_ request: URLRequest, descriptor: any RequestDescriptor) -> URLRequest { request }
    func willSend(_ request: URLRequest, descriptor: any RequestDescriptor) {}
    func didReceive(_ response: Response, descriptor: any RequestDescriptor) {}
    func process(_ response: Response, descriptor: any RequestDescriptor) -> Response { response }
}
