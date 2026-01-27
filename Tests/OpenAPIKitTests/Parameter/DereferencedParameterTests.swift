//
//  DereferencedParameterTests.swift
//  
//
//  Created by Mathew Polzin on 6/22/20.
//

import XCTest
import OpenAPIKit

final class DereferencedParameterTests: XCTestCase {
    func test_inlineSchemaParameter() throws {
        let t1 = try OpenAPI.Parameter.header(
            name: "test",
            schema: .string
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.name, "test")
        XCTAssertEqual(t1.context, .header(schema: .string))
        XCTAssertEqual(
            t1.schemaOrContent.schemaContextValue,
            try OpenAPI.Parameter.SchemaContext.header(.string).dereferenced(in: .noComponents)
        )
        XCTAssertEqual(t1.schemaOrContent.schemaValue?.jsonSchema, .string)
        XCTAssertNil(t1.schemaOrContent.contentValue)

        let t2 = try OpenAPI.Parameter.path(
            name: "test2",
            content: [
                .anyText: .content(.init(schema: .string))
            ]
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t2.name, "test2")
        XCTAssertEqual(t2.context, .path(content: [
                .anyText: .content(.init(schema: .string))
            ]))
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
        let t1 = try OpenAPI.Parameter.header(
            name: "test",
            content: [
                .json: .content(.init(schema: .string))
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
        let t1 = try OpenAPI.Parameter.header(
            name: "test",
            schemaReference: .component(named: "test")
        ).dereferenced(in: components)

        XCTAssertEqual(
            t1.schemaOrContent.schemaValue?.jsonSchema,
            JSONSchema.string.with(vendorExtensions: ["x-component-name": "test"])
        )
    }

    func test_referencedContentParameter() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Parameter.header(
            name: "test",
            content: [.json: .content(.init(schemaReference: .component(named: "test")))]
        ).dereferenced(in: components)

        XCTAssertEqual(
            t1.schemaOrContent.contentValue?[.json]?.schema?.jsonSchema,
            JSONSchema.string.with(vendorExtensions: ["x-component-name": "test"])
        )
    }
}

