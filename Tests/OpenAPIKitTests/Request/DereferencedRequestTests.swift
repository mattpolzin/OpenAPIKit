//
//  DereferencedRequestTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit

final class DereferencedRequestTests: XCTestCase {
    func test_noReferencedComponents() throws {
        let t1 = try OpenAPI.Request(
            description: "test",
            content: [:]
        ).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.content.count, 0)
        // test dynamic member lookup
        XCTAssertEqual(t1.description, "test")
    }

    func test_allInlinedComponents() throws {
        let t1 = try OpenAPI.Request(
            description: "test",
            content: [.json: .content(.init(schema: .string))]
        ).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.content[.json]?.schema?.jsonSchema, .string)
        // test dynamic member lookup
        XCTAssertEqual(t1.description, "test")
    }

    func test_referencedContent() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Request(
            description: "test",
            content: [
                .json: .content(.init(schemaReference: .component(named: "test")))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(
            t1.content[.json]?.schema?.jsonSchema, 
            JSONSchema.string.with(vendorExtensions: ["x-component-name": "test"])
        )
    }

    func test_referencedContentMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Request(
                description: "test",
                content: [
                    .json: .content(.init(schemaReference: .component(named: "test")))
                ]
            ).dereferenced(in: .noComponents)
        )
    }
}
