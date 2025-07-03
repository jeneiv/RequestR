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
    "Tests of RequestQueryStringModifierTask",
    .tags(.requestModifierTaskTests)
)
struct RequestQueryStringModifierTaskTests {

    @Test("Testing the task with empty input. It should return with a request identical to the original")
    func testWithEmptyInput() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        let sut = RequestQueryStringModifierTask(queryItems: [])
        let resultRequest = sut.apply(on: request)

        #expect(request == resultRequest)
    }

    @Test("Testing the task with a standard input map")
    func testWithParameters() throws {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        let paramertersDictionary = [
            "first": "1",
            "second": "2",
            "third": "3"
        ]
        let queryItems = paramertersDictionary.toQueryItems()

        let sut = RequestQueryStringModifierTask(queryItems: queryItems)
        let resultRequest = sut.apply(on: request)

        let queryString = try #require(resultRequest.url?.query)

        let queryParameters = queryString.components(separatedBy: "&").map({
            $0.components(separatedBy: "=")
        }).reduce(into: [String:String]()) { dict, pair in
            if pair.count == 2 {
                dict[pair[0]] = pair[1]
            }
        }
        
        #expect(queryParameters == paramertersDictionary)
    }
}
