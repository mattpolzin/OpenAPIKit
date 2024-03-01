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
            ],
            links: [
                "Link": .link(operationId: "link1")
            ]
        ).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.headers?["Header"]?.underlyingHeader, .init(schema: .string))
        XCTAssertEqual(t1.content[.json]?.underlyingContent, .init(schema: .string))
        XCTAssertEqual(t1.links["Link"], .init(operationId: "link1"))
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
        XCTAssertEqual(
            t1.headers?["Header"]?.underlyingHeader,
            .init(schema: .string, vendorExtensions: ["x-component-name": "test"])
        )
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
        XCTAssertEqual(
            t1.content[.json]?.schema?.jsonSchema,
            JSONSchema.string.with(vendorExtensions: ["x-component-name": "test"])
        )
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

    func test_referencedLink() throws {
        let components = OpenAPI.Components(
            links: [
                "link1": .init(operationId: "linka")
            ]
        )
        let t1 = try OpenAPI.Response(
            description: "test",
            links: [
                "link1": .reference(.component(named: "link1"))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.links["link1"], .init(operationId: "linka", vendorExtensions: ["x-component-name": "link1"]))
    }

    func test_referencedLinkMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Response(
                description: "test",
                links: [
                    "link1": .reference(.component(named: "link1"))
                ]
            ).dereferenced(in: .noComponents)
        )
    }
}
