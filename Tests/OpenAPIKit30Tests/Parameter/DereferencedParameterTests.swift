//
//  DereferencedParameterTests.swift
//  
//
//  Created by Mathew Polzin on 6/22/20.
//

import XCTest
import OpenAPIKit30

final class DereferencedParameterTests: XCTestCase {
    func test_inlineSchemaParameter() throws {
        let t1 = try OpenAPI.Parameter(
            name: "test",
            context: .header,
            schema: .string
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.name, "test")
        XCTAssertEqual(t1.context, .header)
        XCTAssertEqual(
            t1.schemaOrContent.schemaContextValue,
            try OpenAPI.Parameter.SchemaContext.header(.string).dereferenced(in: .noComponents)
        )
        XCTAssertEqual(t1.schemaOrContent.schemaValue?.jsonSchema, .string)
        XCTAssertNil(t1.schemaOrContent.contentValue)

        let t2 = try OpenAPI.Parameter(
            name: "test2",
            context: .path,
            content: [
                .anyText: .init(schema: .string)
            ]
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t2.name, "test2")
        XCTAssertEqual(t2.context, .path)
        XCTAssertEqual(
            t2.schemaOrContent.contentValue,
            [
                .anyText: try OpenAPI.Content(schema: .string).dereferenced(in: .noComponents)
            ]
        )
        XCTAssertNil(t2.schemaOrContent.schemaValue)
        XCTAssertNil(t2.schemaOrContent.schemaContextValue)
    }

    func test_inlineContentParameter() throws {
        let t1 = try OpenAPI.Parameter(
            name: "test",
            context: .header,
            content: [
                .json: .init(schema: .string)
            ]
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema?.jsonSchema, .string)
    }

    func test_referencedSchemaParameter() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Parameter(
            name: "test",
            context: .header,
            schemaReference: .component(named: "test")
        ).dereferenced(in: components)

        XCTAssertEqual(t1.schemaOrContent.schemaValue?.jsonSchema, .string)
    }

    func test_referencedContentParameter() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Parameter(
            name: "test",
            context: .header,
            content: [.json: .init(schemaReference: .component(named: "test"))]
        ).dereferenced(in: components)

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema?.jsonSchema, .string)
    }
}

