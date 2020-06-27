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
        let t1 = try DereferencedHeader(
            OpenAPI.Header(
                schema: .string,
                description: "test"
            ),
            resolvingIn: .noComponents
        )

        XCTAssertEqual(t1.description, "test")
        XCTAssertEqual(t1.schemaOrContent.schemaValue?.underlyingJSONSchema, .string)
    }

    func test_inlineContentHeader() throws {
        let t1 = try DereferencedHeader(
            OpenAPI.Header(
                content: [
                    .json: .init(schema: .string)
                ]
            ),
            resolvingIn: .noComponents
        )

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema.underlyingJSONSchema, .string)
    }

    func test_referencedSchemaHeader() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedHeader(
            OpenAPI.Header(
                schemaReference: .component(named: "test")
            ),
            resolvingIn: components
        )

        XCTAssertEqual(t1.schemaOrContent.schemaValue?.underlyingJSONSchema, .string)
    }

    func test_referencedContentHeader() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedHeader(
            OpenAPI.Header(
                content: [.json: .init(schemaReference: .component(named: "test"))]
            ),
            resolvingIn: components
        )

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema.underlyingJSONSchema, .string)
    }
}
