//
//  Test.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 24..
//

import Foundation
import Testing
@testable import RequestR

struct DictionaryToQueryItemArrayConvertibleTests {
    @Test("testing the extrension function with an empty dictionary")
    func testToQueryItemsOnEmptyDictionary() async throws {
        let dictionary: [String: String] = [:]
        #expect(dictionary.toQueryItems() == [])
    }

    @Test("testing the extrension function with a non-empty dictionary")
    func testToQueryItems() async throws {
        let dictionary: [String: String] = [
            "first": "first",
            "second": "second"
        ]
        let sut = dictionary.toQueryItems()
        #expect(sut.count == 2)
        #expect(sut.contains(where: { queryItem in
            queryItem == URLQueryItem(name: "first", value: "first")
        }) == true)
        #expect(sut.contains(where: { queryItem in
            queryItem == URLQueryItem(name: "second", value: "second")
        }) == true)
    }
}
