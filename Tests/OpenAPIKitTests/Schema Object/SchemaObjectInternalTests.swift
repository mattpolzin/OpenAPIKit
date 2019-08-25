//
//  SchemaObjectInternalTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import XCTest
import AnyCodable
@testable import OpenAPIKit

class SchemaObjectInternalTests: XCTestCase {
    func test_nonFragmentIsNil() {
        XCTAssertNil(JSONSchema.fragmentString(from: ["hello": "world"]))
        XCTAssertNil(JSONSchema.fragmentString(from: ["hello", "world"]))
    }

    func test_fragmentValue() {
        let f1 = JSONSchema.fragmentString(from: true)
        XCTAssertEqual(f1, "true")

        let f2 = JSONSchema.fragmentString(from: 10)
        XCTAssertEqual(f2, "10")

        let f3 = JSONSchema.fragmentString(from: 11.3)
        XCTAssertEqual(f3, "11.3")

        let f4 = JSONSchema.fragmentString(from: Float(3.4))
        XCTAssertEqual(f4, "3.4")

        let f5 = JSONSchema.fragmentString(from: "hello world")
        XCTAssertEqual(f5, "\"hello world\"")
    }
}
