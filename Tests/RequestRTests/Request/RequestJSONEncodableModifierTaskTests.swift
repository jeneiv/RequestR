//
//  Test.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 24..
//

import Foundation
import Testing
@testable import RequestR

@Suite(
    "Tests of RequestJSONEncodableModifierTask",
    .tags(.requestModifierTaskTests)
)
struct RequestJSONEncodableModifierTests {
    @Test("Testing the constructor")
    func testInit() {
        let encodable = ["some string", "some toher string"]
        let encoder = JSONEncoder()

        let sut = RequestJSONEncodableModifierTask(encodable: encodable, encoder: encoder)

        #expect(sut.encodable as? [String] == encodable)
        #expect(sut.encoder === encoder)
    }

    @Test("Testing JSONEncodableModifier's constructor with a default encoder")
    func testConstructorWithoutProvidedEncoder() {
        let aCustomJSONEncoder = JSONEncoder()
        let sut = RequestJSONEncodableModifierTask(encodable: ["String"])
        #expect(sut.encoder !== aCustomJSONEncoder)
    }
    
    @Test("Testing JSONEncodableModifier's constructor with a provided encoder")
    func testConstructorWithProvidedEncoder() {
        let customJSONEncoder = JSONEncoder()
        let sut = RequestJSONEncodableModifierTask(encodable: ["String"], encoder: customJSONEncoder)
        #expect(sut.encoder === customJSONEncoder)
    }
    
    @Test("Test if JSON Data is added to the request body")
    func testingRequestBody() throws {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        let encodable: [String: String] = ["key": "value"]
        let sut = RequestJSONEncodableModifierTask(encodable: encodable)
        let resultRequest = try sut.apply(on: request)
        
        let encodedData = try JSONEncoder().encode(encodable)
        #expect(resultRequest.httpBody == encodedData)
    }
    
    @Test("Test if Content-type header is added in case it's missing")
    func testingRequestAdditionalHeader() throws {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        let encodable: [String: String] = ["key": "value"]
        let sut = RequestJSONEncodableModifierTask(encodable: encodable)
        let resultingRequest = try sut.apply(on: request)

        #expect(resultingRequest.allHTTPHeaderFields?.contains(where: { key, value in
            key == "Content-Type" && value == "application/json"
        }) ?? false)
    }

    @Test("Test if on JSONEncoder.encode error the proper error is thrown")
    func testJSONENcoderError() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        // `Double.infinity` makes JSONEncoder.encode fail
        let encodable: [String: Double] = ["key": Double.infinity]
        let sut = RequestJSONEncodableModifierTask(encodable: encodable)

        #expect(throws: RequestModifierTaskError.self, performing: {
            let _ = try sut.apply(on: request)
        })
    }
}
