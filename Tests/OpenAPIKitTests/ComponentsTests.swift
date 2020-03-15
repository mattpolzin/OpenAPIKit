//
//  ComponentsTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ComponentsTests: XCTestCase {
    func test_referenceLookup() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .string,
                "world": .integer(required: false)
            ]
        )

        let ref1 = JSONReference<JSONSchema>.component(named: "world")
        let ref2 = JSONReference<JSONSchema>.component(named: "missing")
        let ref3 = JSONReference<OpenAPI.PathItem.Parameter>.component(named: "param")

        XCTAssertEqual(components[ref1], .integer(required: false))
        XCTAssertNil(components[ref2])
        XCTAssertNil(components[ref3])

        let ref4 = JSONReference<JSONSchema>.InternalReference.component(name: "world")
        let ref5 = JSONReference<JSONSchema>.InternalReference.component(name: "missing")
        let ref6 = JSONReference<OpenAPI.PathItem.Parameter>.InternalReference.component(name: "param")

        XCTAssertEqual(components[ref4], .integer(required: false))
        XCTAssertNil(components[ref5])
        XCTAssertNil(components[ref6])

        let ref7 = JSONReference<JSONSchema>.external(URL(string: "hello.json")!)

        XCTAssertNil(components[ref7])

        XCTAssertThrowsError(try components.contains(ref7))
    }

    func test_referenceCreation() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .string,
                "world": .integer(required: false)
            ]
        )

        let ref1 = try components.reference(named: "hello", ofType: JSONSchema.self)
        let ref2 = try components.reference(named: "world", ofType: JSONSchema.self)
        XCTAssertEqual(ref1, .component(named: "hello"))
        XCTAssertEqual(ref2, .component(named: "world"))

        XCTAssertThrowsError(try components.reference(named: "missing", ofType: JSONSchema.self))
        XCTAssertThrowsError(try components.reference(named: "hello", ofType: OpenAPI.PathItem.Parameter.self))
    }

    // TODO: write tests
}

// MARK: - Codable Tests
extension ComponentsTests {
    // TODO: write tests
}
