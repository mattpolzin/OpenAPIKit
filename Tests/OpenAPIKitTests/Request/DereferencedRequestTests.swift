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
        let t1 = try DereferencedRequest(
            OpenAPI.Request(
                description: "test",
                content: [:]
            ),
            resolvingIn: .noComponents
        )
        XCTAssertEqual(t1.content.count, 0)
        // test dynamic member lookup
        XCTAssertEqual(t1.description, "test")
    }

    func test_allInlinedComponents() throws {
        let t1 = try DereferencedRequest(
            OpenAPI.Request(
                description: "test",
                content: [.json: .init(schema: .string)]
            ),
            resolvingIn: .noComponents
        )
        XCTAssertEqual(t1.content[.json]?.schema.underlyingJsonSchema, .string)
        // test dynamic member lookup
        XCTAssertEqual(t1.description, "test")
    }

    func test_referencedContent() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedRequest(
            OpenAPI.Request(
                description: "test",
                content: [
                    .json: .init(schemaReference: .component(named: "test"))
                ]
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.content[.json]?.schema.underlyingJsonSchema, .string)
    }

    func test_referencedContentMissing() {
        XCTAssertThrowsError(
            try DereferencedRequest(
                OpenAPI.Request(
                    description: "test",
                    content: [
                        .json: .init(schemaReference: .component(named: "test"))
                    ]
                ),
                resolvingIn: .noComponents
            )
        )
    }
}
