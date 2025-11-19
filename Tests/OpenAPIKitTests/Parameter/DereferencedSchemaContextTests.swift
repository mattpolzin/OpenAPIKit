//
//  DereferencedSchemaContextTests.swift
//  
//
//  Created by Mathew Polzin on 6/22/20.
//

import XCTest
import OpenAPIKit

final class DereferencedSchemaContextTests: XCTestCase {
    func test_oneExampleInline() throws {
        let t1 = try OpenAPI.Parameter.SchemaContext(
            .string,
            style: .default(for: .header),
            example: "hello world"
        ).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(t1.schema.jsonSchema, .string)
        // test dynamic member access:
        XCTAssertEqual(t1.style, .default(for: .header))
    }

    func test_oneExampleReferenced() throws {
        let components = OpenAPI.Components.direct(
            examples: ["test": .init(value: .init("hello world"))]
        )
        let t1 = try OpenAPI.Parameter.SchemaContext(
            .string,
            style: .default(for: .header),
            examples: ["test": .reference(.component(named: "test"))]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(
            t1.examples, 
            ["test": .init(value: .init("hello world"), vendorExtensions: ["x-component-name": "test"])]
        )
    }

    func test_multipleExamplesReferenced() throws {
        let components = OpenAPI.Components.direct(
            examples: [
                "test1": .init(value: .init("hello world")),
                "test2": .init(value: .a(URL(string: "http://website.com")!))
            ]
        )
        let t1 = try OpenAPI.Parameter.SchemaContext(
            .string,
            style: .default(for: .header),
            examples: [
                "test1": .reference(.component(named: "test1")),
                "test2": .reference(.component(named: "test2"))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(
            t1.examples,
            [
                "test1": .init(value: .init("hello world"), vendorExtensions: ["x-component-name": "test1"]),
                "test2": .init(value: .init(URL(string: "http://website.com")!), vendorExtensions: ["x-component-name": "test2"])
            ]
        )
    }

    func test_missingExample() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(
            try OpenAPI.Parameter.SchemaContext(
                .string,
                style: .default(for: .header),
                examples: ["test": .reference(.component(named: "test"))]
            ).dereferenced(in: components)
        )
    }

    func test_referencedSchema() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Parameter.SchemaContext(
            schemaReference: .component(named: "test"),
            style: .default(for: .header)
        ).dereferenced(in: components)
        XCTAssertEqual(
            t1.schema, 
            DereferencedJSONSchema.string(.init(), .init()).with(vendorExtensions: ["x-component-name": "test"])
        )
    }

    func test_missingSchema() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(
            try OpenAPI.Parameter.SchemaContext(
                schemaReference: .component(named: "missing"),
                style: .default(for: .header)
            ).dereferenced(in: components)
        )
    }
}
