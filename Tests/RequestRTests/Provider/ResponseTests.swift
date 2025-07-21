//
//  ResponseTests.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 07. 21..
//

import Foundation
import Testing
@testable import RequestR

struct ResponseTests {
    private static let url = URL(string: "http://example.com")!
    
    var redirectionResponse: Response {
        Response(
            statusCode: 301,
            data: Data(),
            request: URLRequest(url: Self.url),
            response: HTTPURLResponse(url: Self.url, statusCode: 301, httpVersion: nil, headerFields: nil)!
        )
    }
    
    var successResponse: Response {
        Response(
            statusCode: 200,
            data: Data(),
            request: URLRequest(url: Self.url),
            response: HTTPURLResponse(url: Self.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
    }
    
    var clientErrorResponse: Response {
        Response(
            statusCode: 403,
            data: Data(),
            request: URLRequest(url: Self.url),
            response: HTTPURLResponse(url: Self.url, statusCode: 403, httpVersion: nil, headerFields: nil)!
        )
    }
    
    var serverErrorResponse: Response {
        Response(
            statusCode: 501,
            data: Data(),
            request: URLRequest(url: Self.url),
            response: HTTPURLResponse(url: Self.url, statusCode: 501, httpVersion: nil, headerFields: nil)!
        )
    }
    
    @Test("Testintg `isSuccessful` computed variable")
    func testIsSuccessfulComputedVar() {
        #expect(redirectionResponse.isSuccessResponse == false)
        #expect(successResponse.isSuccessResponse == true)
        #expect(clientErrorResponse.isSuccessResponse == false)
        #expect(serverErrorResponse.isSuccessResponse == false)
    }
    
    @Test("Testintg `isRedirection` computed variable")
    func testIsRedirectionComputedVar() {
        #expect(redirectionResponse.isRedirectionResponse == true)
        #expect(successResponse.isRedirectionResponse == false)
        #expect(clientErrorResponse.isRedirectionResponse == false)
        #expect(serverErrorResponse.isRedirectionResponse == false)
    }
    
    @Test("Testintg `isClientErrorResponse` computed variable")
    func testIsClientErrorResponseComputedVar() {
        #expect(redirectionResponse.isClientErrorResponse == false)
        #expect(successResponse.isClientErrorResponse == false)
        #expect(clientErrorResponse.isClientErrorResponse == true)
        #expect(serverErrorResponse.isClientErrorResponse == false)
    }
    
    @Test("Testintg `isServerErrorResponse` computed variable")
    func testIsServerErrorResponseComputedVar() {
        #expect(redirectionResponse.isServerErrorResponse == false)
        #expect(successResponse.isServerErrorResponse == false)
        #expect(clientErrorResponse.isServerErrorResponse == false)
        #expect(serverErrorResponse.isServerErrorResponse == true)
    }
}
