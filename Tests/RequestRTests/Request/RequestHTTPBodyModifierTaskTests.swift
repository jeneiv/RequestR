//
//  Test.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 25..
//

import Foundation
import Testing
@testable import RequestR

@Suite(
    "Tests of RequestHTTPBodyModifier",
    .tags(.requestModifierTaskTests)
)
struct RequestHTTPBodyModifierTests {
    @Test("Testing if httpBody is added")
    func testHTTPBody() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        let data = "Hello, World!".data(using: .utf8)!
        
        let sut = RequestHTTPBodyModifierTask(data: data)
        let resultRequest = sut.apply(on: request)

        #expect(resultRequest.httpBody == data)
    }
}
