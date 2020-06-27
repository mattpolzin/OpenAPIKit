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
        let t1 = try DereferencedSchemaContext(OpenAPI.Parameter.SchemaContext(
            .string,
            style: .default(for: .header),
            example: "hello world"
        ), resolvingIn: .noComponents)
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(t1.schema.underlyingJSONSchema, .string)
        // test dynamic member access:
        XCTAssertEqual(t1.style, .default(for: .header))
    }

    func test_oneExampleReferenced() throws {
        let components = OpenAPI.Components(
            examples: ["test": .init(value: .init("hello world"))]
        )
        let t1 = try DereferencedSchemaContext(
            OpenAPI.Parameter.SchemaContext(
                .string,
                style: .default(for: .header),
                examples: ["test": .reference(.component(named: "test"))]
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(t1.examples, ["test": .init(value: .init("hello world"))])
    }

    func test_multipleExamplesReferenced() throws {
        let components = OpenAPI.Components(
            examples: [
                "test1": .init(value: .init("hello world")),
                "test2": .init(value: .a(URL(string: "http://website.com")!))
            ]
        )
        let t1 = try DereferencedSchemaContext(
            OpenAPI.Parameter.SchemaContext(
                .string,
                style: .default(for: .header),
                examples: [
                    "test1": .reference(.component(named: "test1")),
                    "test2": .reference(.component(named: "test2"))
                ]
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(
            t1.examples,
            [
                "test1": .init(value: .init("hello world")),
                "test2": .init(value: .init(URL(string: "http://website.com")!))
            ]
        )
    }

    func test_missingExample() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(
            try DereferencedSchemaContext(
                OpenAPI.Parameter.SchemaContext(
                    .string,
                    style: .default(for: .header),
                    examples: ["test": .reference(.component(named: "test"))]
                ),
                resolvingIn: components
            )
        )
    }

    func test_referencedSchema() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedSchemaContext(
            OpenAPI.Parameter.SchemaContext(
                schemaReference: .component(named: "test"),
                style: .default(for: .header)
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.schema, .string(.init(), .init()))
    }

    func test_missingSchema() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(
            try DereferencedSchemaContext(
                OpenAPI.Parameter.SchemaContext(
                    schemaReference: .component(named: "missing"),
                    style: .default(for: .header)
                ),
                resolvingIn: components
            )
        )
    }
}
