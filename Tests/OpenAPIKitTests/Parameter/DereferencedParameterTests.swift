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
        let t1 = try DereferencedParameter(
            OpenAPI.Parameter(
                name: "test",
                context: .header,
                schema: .string
            ),
            resolvingIn: .noComponents
        )

        XCTAssertEqual(t1.name, "test")
        XCTAssertEqual(t1.context, .header)
        XCTAssertEqual(t1.schemaOrContent.schemaValue?.underlyingJSONSchema, .string)
    }

    func test_inlineContentParameter() throws {
        let t1 = try DereferencedParameter(
            OpenAPI.Parameter(
                name: "test",
                context: .header,
                content: [
                    .json: .init(schema: .string)
                ]
            ),
            resolvingIn: .noComponents
        )

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema.underlyingJSONSchema, .string)
    }

    func test_referencedSchemaParameter() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedParameter(
            OpenAPI.Parameter(
                name: "test",
                context: .header,
                schemaReference: .component(named: "test")
            ),
            resolvingIn: components
        )

        XCTAssertEqual(t1.schemaOrContent.schemaValue?.underlyingJSONSchema, .string)
    }

    func test_referencedContentParameter() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedParameter(
            OpenAPI.Parameter(
                name: "test",
                context: .header,
                content: [.json: .init(schemaReference: .component(named: "test"))]
            ),
            resolvingIn: components
        )

        XCTAssertEqual(t1.schemaOrContent.contentValue?[.json]?.schema.underlyingJSONSchema, .string)
    }
}

