//
//  DereferencedResponseTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit

final class DereferencedResponseTests: XCTestCase {
    func test_noReferencedComponents() throws {
        let t1 = try OpenAPI.Response(description: "test").dereferenced(in: .noComponents)
        XCTAssertNil(t1.headers)
        XCTAssertEqual(t1.content.count, 0)
        // test dynamic member lookup
        XCTAssertEqual(t1.description, "test")
    }

    func test_allInlinedComponents() throws {
        let t1 = try OpenAPI.Response(
            description: "test",
            headers: [
                "Header": .header(.init(schema: .string))
            ],
            content: [
                .json: .init(schema: .string)
            ]
        ).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.headers?["Header"]?.underlyingHeader, .init(schema: .string))
        XCTAssertEqual(t1.content[.json]?.underlyingContent, .init(schema: .string))
    }

    func test_referencedHeader() throws {
        let components = OpenAPI.Components(
            headers: [
                "test": .init(schema: .string)
            ]
        )
        let t1 = try OpenAPI.Response(
            description: "test",
            headers: [
                "Header": .reference(.component(named: "test"))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.headers?["Header"]?.underlyingHeader, .init(schema: .string))
    }

    func test_referencedHeaderMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Response(
                description: "test",
                headers: [
                    "Header": .reference(.component(named: "test"))
                ]
            ).dereferenced(in: .noComponents)
        )
    }

    func test_referencedContent() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Response(
            description: "test",
            content: [
                .json: .init(schemaReference: .component(named: "test"))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.content[.json]?.schema?.jsonSchema, .string)
    }

    func test_referencedContentMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Response(
                description: "test",
                content: [
                    .json: .init(schemaReference: .component(named: "test"))
                ]
            ).dereferenced(in: .noComponents)
        )
    }
}
