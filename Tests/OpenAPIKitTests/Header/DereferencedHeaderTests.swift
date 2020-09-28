//
//  DereferencedHeaderTests.swift
//  
//
//  Created by Mathew Polzin on 6/22/20.
//

import XCTest
import OpenAPIKit

final class DereferencedHeaderTests: XCTestCase {
    func test_inlineSchemaHeader() throws {
        let t1 = try OpenAPI.Header(
            schema: .string,
            description: "test"
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.description, "test")
        XCTAssertEqual(t1.schemaOrContent.schemaValue?.jsonSchema, .string)
    }

    func test_inlineContentHeader() throws {
        let t1 = try OpenAPI.Header(
            content: [
                .json: .init(schema: .string)
            ]
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema?.jsonSchema, .string)
    }

    func test_referencedSchemaHeader() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Header(
            schemaReference: .component(named: "test")
        ).dereferenced(in: components)

        XCTAssertEqual(t1.schemaOrContent.schemaValue?.jsonSchema, .string)
    }

    func test_referencedContentHeader() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Header(
            content: [.json: .init(schemaReference: .component(named: "test"))]
        ).dereferenced(in: components)

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema?.jsonSchema, .string)
    }
}
