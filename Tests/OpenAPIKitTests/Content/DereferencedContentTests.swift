//
//  DereferencedContentTests.swift
//  
//
//  Created by Mathew Polzin on 6/21/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class DereferencedContentTests: XCTestCase {
    func test_oneExampleInline() throws {
        let t1 = try DereferencedContent(OpenAPI.Content(schema: .string, example: "hello world"), resolvingIn: .noComponents)
        XCTAssertEqual(t1.example, "hello world")
    }

    func test_oneExampleReferenced() throws {
        let components = OpenAPI.Components(
            examples: ["test": .init(value: .init("hello world"))]
        )
        let t1 = try DereferencedContent(
            OpenAPI.Content(
                schema: .string,
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
        let t1 = try DereferencedContent(
            OpenAPI.Content(
                schema: .string,
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
            try DereferencedContent(
                OpenAPI.Content(
                    schema: .string,
                    examples: ["test": .reference(.component(named: "test"))]
                ),
                resolvingIn: components
            )
        )
    }

    func test_inlineSchema() throws {
        let t1 = try DereferencedContent(OpenAPI.Content(schema: .string), resolvingIn: .noComponents)
        XCTAssertEqual(t1.schema, .string(.init(), .init()))
    }

    func test_referencedSchema() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try DereferencedContent(
            OpenAPI.Content(
                schemaReference: .component(named: "test")
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.schema, .string(.init(), .init()))
    }

    func test_missingSchema() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(
            try DereferencedContent(
                OpenAPI.Content(
                    schemaReference: .component(named: "missing")
                ),
                resolvingIn: components
            )
        )
    }

    func test_inlineEncoding() throws {
        let t1 = try DereferencedContent(OpenAPI.Content(schema: .string, encoding: ["test": .init()]), resolvingIn: .noComponents)
        XCTAssertEqual(t1.encoding, ["test": try .init(.init(), resolvingIn: .noComponents)])
    }

    func test_referencedHeaderInEncoding() throws {
        let components = OpenAPI.Components(
            headers: [
                "test": OpenAPI.Header(schema: .string)
            ]
        )
        let t1 = try DereferencedContent(
            OpenAPI.Content(
                schema: .string,
                encoding: [
                    "test": .init(
                        headers: [
                            "test": .reference(.component(named: "test"))
                        ]
                    )
                ]
            ),
            resolvingIn: components
        )
        XCTAssertEqual(
            t1.encoding?["test"]?.headers?["test"]?.schemaOrContent.schemaValue,
            DereferencedJSONSchema.string(.init(), .init())
        )
        // just test that dynamic member lookup is connected correctly
        XCTAssertEqual(t1.encoding?["test"]?.style, OpenAPI.Content.Encoding.defaultStyle)
    }

    func test_missingHeaderInEncoding() {
        XCTAssertThrowsError(
            try DereferencedContent(
                OpenAPI.Content(
                    schema: .string,
                    encoding: [
                        "test": .init(
                            headers: [
                                "test": .reference(.component(named: "test"))
                            ]
                        )
                    ]
                ),
                resolvingIn: .noComponents
            )
        )
    }

    func test_vendorExtensionThroughUnderlyingContent() throws {
        let content = OpenAPI.Content(schema: .string, vendorExtensions: ["hello": "world"])
        let dereferencedContent = try DereferencedContent(content, resolvingIn: .noComponents)
        XCTAssertEqual(dereferencedContent.vendorExtensions, content.vendorExtensions)
    }
}
