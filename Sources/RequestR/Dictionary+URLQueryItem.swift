//
//  Dictionary+URLQueryItem.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation

public extension Dictionary where Key == String, Value == String {
    func toQueryItems() -> [URLQueryItem] {
        self.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
