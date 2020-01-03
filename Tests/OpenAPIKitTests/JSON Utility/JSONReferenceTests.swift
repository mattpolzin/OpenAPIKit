//
//  JSONReferenceTests.swift
//  
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import XCTest
import OpenAPIKit

fileprivate struct Root: ReferenceRoot {
    static var refName: String { return "root" }

    struct Thing: ReferenceDict {

        typealias Value = JSONSchema

        static var refName: String { return "thing" }

        func contains(_ key: String) -> Bool {
            return true
        }
    }

    let thing: Thing
}

// MARK: - JSONReference
final class JSONReferenceTests: XCTestCase {
    func test_initialization() {
        let _ = JSONReference<Root, JSONSchema>.internal(.unsafe("#/hello"))

        let _ = JSONReference<Root, JSONSchema>.internal(.node(.init(path: \.thing, selector: "hello")))

        let _ = JSONReference<Root, JSONSchema>.external("hello.yml", nil)

        let _ = JSONReference<Root, JSONSchema>.external("hello.yml", .unsafe("#/hello"))

        let _ = JSONReference<Root, JSONSchema>.external("hello.yml", .unsafe("hello"))

        let _ = JSONReference<Root, JSONSchema>.external("hello.yml", .node(.init(path: \.thing, selector: "hello")))

        let ref = JSONReference<Root, JSONSchema>.external("hello.yml#/hello")

        XCTAssertEqual(ref, .external("hello.yml", .unsafe("#/hello")))
    }

    func test_descriptions() {
        XCTAssertEqual(JSONReference<Root, JSONSchema>.internal(.unsafe("#/hello")).description, "#/hello")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.internal(.unsafe("hello")).description, "#/hello")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.internal(.node(.init(path: \.thing, selector: "hello"))).description, "#/root/thing/hello")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.external("hello.yml", nil).description, "hello.yml")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.external("hello.yml", .unsafe("#/hello")).description, "hello.yml#/hello")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.external("hello.yml", .unsafe("hello")).description, "hello.yml#/hello")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.external("hello.yml", .node(.init(path: \.thing, selector: "hello"))).description, "hello.yml#/root/thing/hello")

        XCTAssertEqual(JSONReference<Root, JSONSchema>.external("hello.yml#/hello").description, "hello.yml#/hello")
    }
}

// MARK: Codable
extension JSONReferenceTests {
    // TODO: write more tests
}

// MARK: - RefDict
extension JSONReferenceTests {
    // TODO: write tests
}

// MARK: Codable
extension JSONReferenceTests {
    // TODO: write more tests
}
